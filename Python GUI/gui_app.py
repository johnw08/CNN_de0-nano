# import libraries
import cv2
import serial
import numpy as np
from tkinter import *
import tkinter.ttk as ttk
from PIL import ImageGrab, ImageTk, Image
from keras.models import load_model
from keras.datasets import mnist
from PyQt5 import QtGui as qtGui
import threading
import tensorflow as tf
from tensorflow.python.keras.utils.np_utils import to_categorical


def activate_event(event):
    """Draw line on the canvas when cursor is moved while
    the left mouse button is being hold and update the cursor.
    """
    global last_x, last_y, canvas
    last_x, last_y = event.x, event.y
    canvas.bind('<B1-Motion>', draw_lines)


def draw_lines(event):
    """Draw a new line between the current cursor position
    and the last one.
    """
    global last_x, last_y, canvas
    x, y = event.x, event.y
    canvas.create_line((last_x, last_y, x, y), width=17, fill='black'
                       , capstyle=ROUND, joinstyle=MITER, smooth=TRUE, splinesteps=12)
    last_x, last_y = x, y


def clear():
    """ Delete all the content on both canvas."""
    global canvas, display, mode
    canvas.delete("all")
    display.delete("all")


def recognize_draw():
    """Identify all the digits currently drew on
    the canvas and display the result.
    """
    global canvas
    file_name = 'image_draw.png'
    widget = canvas

    # Extract the physical pixel / logical pixel ratio and calculate.
    devicePixel_ratio = int(qtGui.QGuiApplication(sys.argv).devicePixelRatio())
    # Calculate the canvas diagonal coordinate in logical pixel.
    x = widget.winfo_rootx() * devicePixel_ratio
    y = widget.winfo_rooty() * devicePixel_ratio
    x1 = x + widget.winfo_width() * devicePixel_ratio
    y1 = y + widget.winfo_height() * devicePixel_ratio

    # Take a screenshot of the canvas area and save the image.
    ImageGrab.grab((x, y, x1, y1)).save(file_name)

    # Read the image in color format.
    image = cv2.imread(file_name, cv2.IMREAD_COLOR)

    # Convert the image in grayscale.
    image_gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)

    # Applying Otsu threshold to convert the image to binary.
    thresh, image_binary = cv2.threshold(image_gray, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)

    # Extract individual numbers in the screenshot.
    contours = cv2.findContours(image_binary, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]

    sr = serial.Serial('/dev/cu.usbserial', baudrate=230400
                       , bytesize=serial.EIGHTBITS
                       , stopbits=serial.STOPBITS_ONE
                       , parity=serial.PARITY_NONE)
    sr.reset_output_buffer()
    sr.reset_input_buffer()
    # Iterate each contour to identify individual numbers.
    for cnt in contours:
        # Get bounding box to extract ROI.
        x, y, w, h = cv2.boundingRect(cnt)

        # Extract the region of interest from the grayscale image and invert it.
        roi = image_gray[y:y + h, x:x + w]
        roi = (255 - roi)

        # Adding padding to the image for better recognition.
        # Update the dimension.
        v_margin = int(0.3 * w)
        h_margin = int(0.3 * h)
        wp = w + 2 * h_margin
        hp = h + 2 * v_margin
        roi_pad = np.ones((hp, wp), dtype=np.uint8)
        roi_pad[v_margin:v_margin + h, h_margin:h_margin + w] = roi

        # Resize the image to 28 * 28 pixel in scale.
        # Scale the image first until one of its dimension is 28.
        if wp > hp:
            wr = int(28)
            hr = int((wr * hp) / wp)
        else:
            hr = int(28)
            wr = int((hr * wp) / hp)
        image_scale = cv2.resize(roi_pad, (int(wr), int(hr)), interpolation=cv2.INTER_AREA)

        # Fill the padding to make its other dimension 28.
        image_28 = np.ones((28, 28), dtype=np.uint8)
        if wp > hp:
            start_y = 14 - int(hr / 2)
            end_y = start_y + hr
            image_28[int(start_y):int(end_y), :] = image_scale
        else:
            start_x = 14 - int(wr / 2)
            end_x = start_x + wr
            image_28[:, int(start_x):int(end_x)] = image_scale

        # for 99% accurate SW model
        image_sw = image_28.reshape(1, 28, 28, 1).astype('float32')
        image_sw = image_sw / 255

        # for 96% accurate HW model
        image_hw = cv2.threshold(image_28, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
        image_hw = image_hw.reshape(28, 28, 1).astype('int8')

        # plt.subplot(121)
        # plt.imshow(image_28[0], 'gray')
        # plt.subplot(122)
        # plt.imshow(image_empty[0], 'binary')
        # plt.show()

        # Feed the image into ML model to predict the result.
        # SW
        result_sw = np.argmax(model.predict([image_sw])[0])
        # HW
        image_hw = tf.reshape(image_hw, [-1])
        for o in range(91):
            image_byte = 0
            for k in range(8):
                b = abs(int(image_hw[8 * o + k]))
                b = b << k
                image_byte = image_byte + b
            image_byte = image_byte.to_bytes(1, byteorder='big')
            # print(image_byte)
            sr.write(image_byte)
        result_hw = int.from_bytes(sr.read(), "big")

        # Display the result on the display canvas at the same relative position.
        dis_x = int((x + w / 2) / devicePixel_ratio)
        dis_y = int((y + h / 2) / devicePixel_ratio)
        size = int((w + h) / (2 * devicePixel_ratio))
        if result_sw == result_hw:
            color = 'green'
        else:
            color = 'red'
        display.create_text(dis_x, dis_y, text=str(result_sw)
                            , font='Times ' + str(size), justify=CENTER
                            , fill=color)
    sr.flushInput()
    sr.flushOutput()
    sr.close()


def load():
    # """Create a new thread for mnist evaluation"""
    load_thread = threading.Thread(target=load_mnist)
    load_thread.start()


# @profile
def load_mnist():
    """Loading MNIST image and evaluate the model."""
    global stop_load, bsy
    if bsy:
        return
    bsy = 1
    clear()
    progress['value'] = 0
    stat.set('0%')
    eva.set("-- Model Evaluating:   0/70000")
    acc.set("-- Model Accuracy: ")
    accuracy = 0
    sr = serial.Serial('/dev/cu.usbserial', baudrate=230400
                       , bytesize=serial.EIGHTBITS
                       , stopbits=serial.STOPBITS_ONE
                       , timeout=None
                       , parity=serial.PARITY_NONE)
    sr.reset_input_buffer()
    sr.reset_output_buffer()
    err_cnt = 0
    try:
        for idx in range(70000):
            if stop_load == 1:
                break
            label = y_image[idx]
            sr.write(x_sent[idx])
            pre = sr.read()
            predict_hw = int.from_bytes(pre, "big")
            # predict_sw = np.argmax(model_eva.predict([x_image[idx:idx+1]])[0])
            # if predict_sw != predict_hw:
            #     print(idx,  end=': ')
            #     print(predict_sw, end=',  ')
            #     print(predict_hw)
            #     break

            # print(str(predict_hw) + "  " + str(predict_sw) + "  " + str(idx))

            cor = 0
            if label == predict_hw:
                accuracy += 1
                cor = 1
            else:
                err_cnt += 1

            if (idx + 1) % 700 == 0:
                progress_thread = threading.Thread(target=update_progressbar, args=(int(idx + 1),))
                progress_thread.start()
                progress_thread = threading.Thread(target=update_accuracy, args=(accuracy / (idx + 1),))
                progress_thread.start()
            if (idx % 1000 == 0) or (cor == 0 and err_cnt % 30 == 0):
                display_thread = threading.Thread(target=eva_display, args=(idx, cor, predict_hw, label,))
                display_thread.start()
    except KeyboardInterrupt:
        print("KeyboardInterrupt")
        sr.flushInput()
        sr.flushOutput()
        sr.close()
        bsy = 0
        return

    # Calculate and display accuracy
    if stop_load == 1:
        # print(q)
        stop_load = 0
        progress['value'] = 0
        stat.set('0%')
        eva.set("-- Evaluation Quit --         ")
        acc.set("")

    sr.flushInput()
    sr.flushOutput()
    sr.close()
    bsy = 0


def update_progressbar(comp):
    """Display mnist image and predicted result during evaluation"""
    perc = int(comp / 700)
    progress['value'] = int(perc)
    stat.set(str(perc) + "%")
    if comp == 70000:
        eva.set("-- Evaluation Done:    " + str(comp) + "/70000")
    else:
        eva.set("-- Model Evaluating:   " + str(comp) + "/70000")


def update_accuracy(acc_temp):
    acc.set("-- Model Accuracy:     " + "{:.4f}".format(acc_temp * 100) + "%.")


def eva_display(idx, cor, pre_hw, la):
    """Display mnist image and predicted result during evaluation"""
    global dis_bsy
    # if dis_bsy == 1:
    #     return
    while dis_bsy == 1:
        pass
    dis_bsy = 1
    image = img_dis[idx]
    root.image = image

    canvas.create_image(canvas.winfo_width() / 2, canvas.winfo_height() / 2, image=image)
    display.delete('all')
    if cor == 1:
        display.create_text(display.winfo_width() / 2, display.winfo_height() / 2
                            , text=str(pre_hw), fill='green', font='Times ' + str(250)
                            , justify=CENTER)
    else:
        display.create_text(display.winfo_width() / 2, display.winfo_height() / 2
                            , text=str(pre_hw), fill='red', font='Times ' + str(250)
                            , justify=CENTER)
        display.create_text(display.winfo_width() * 3 / 4, display.winfo_height() * 3 / 4
                            , text=str(la), fill='green', font='Times ' + str(100)
                            , justify=CENTER)

    if idx == 69999:
        clear()
    dis_bsy = 0


def load_m():
    """Load model file from input path."""
    global model, mod
    try:
        model = load_model(model_input.get())
    except IOError:
        mod.set("-- Model: file doesn't exit.")
        return
    mod.set("-- Model: " + model_input.get() + ".")


def stop(event):
    """Quit the MNIST image evaluating process when esc is pressed."""
    global stop_load
    stop_load = 1


def term():
    """Quit the MNIST image evaluating process when stop button is pressed."""
    global stop_load
    stop_load = 1


# Initialize ML model.
# model_eva = load_model('CNN_bi_int.h5')
model = load_model('model.h5')

# Load MNIST data set
(x_train, y_train), (x_test, y_test) = mnist.load_data()

# Combine labels
y_image = np.concatenate((y_train, y_test))
# # Convert class vector (integer) to binary class matrix.
# y_image_b = to_categorical(y_image)

# Combine and reformat testing images.
x_con = np.concatenate((x_train, x_test))
# for i, x in enumerate(x_con):
#     x_con[i] = cv2.threshold(x, 0, 255, cv2.THRESH_BINARY_INV + cv2.THRESH_OTSU)[1]
# x_image = x_con.reshape(70000, 28, 28, 1).astype('int8')

# Load mnist evaluation data
folder = "./"
file = open(folder + "mnist_byte.txt", "rb")
x_sent = [[bytes] for i in range(70000)]
for i in range(70000):
    a = file.read(91)
    x_sent[i] = a
file.close()
print('MNIST images load successfully')

img_dis = [None] * 70000
for k in range(70000):
    if k % 1000 == 0:
        img = cv2.resize(x_con[jj], (300, 300), interpolation=cv2.INTER_AREA)
        img = Image.fromarray(img)
        img = ImageTk.PhotoImage(img)
        img_dis[k] = img

f_img = open(folder + "img_ini.txt", "r")
while True:
    line = f_img.readline()
    if not line:
        break
    index = int(line)
    img = cv2.resize(x_con[index], (300, 300), interpolation=cv2.INTER_AREA)
    img = Image.fromarray(img)
    img = ImageTk.PhotoImage(img)
    img_dis[index] = img
f_img.close()

# Set up GUI
# Create the root window.
root = Tk()
root.resizable(0, 0)
root.config(bg='gainsboro')
root.title('Handwritten Digits Recognizer')
root.columnconfigure((0, 1), weight=1, uniform='foo')

# Initialize the current cursor coordinate.
last_x, last_y = None, None

p0 = Frame(root, width=400, height=5, bg='gainsboro', highlightthickness=0)
p0.grid(row=0, column=0, columnspan=1, padx=(15, 5), pady=(10, 0), sticky='nwe')

# Create an instruction text on the top.
text = Label(p0, text='Click and hold left mouse button to write.\n\nDraw below.', width=40, height=3,
             highlightbackground='gainsboro', bg='gainsboro')
text.config(anchor='nw', justify=LEFT, padx=0)
text.grid(row=0, column=0, columnspan=4, padx=0, pady=(0, 0), sticky='nws')
green = Canvas(p0, width=20, height=20, bg='lime green', highlightthickness=0)
green.grid(row=2, column=0, padx=0, pady=(25, 0), columnspan=1, sticky='ew')
red = Canvas(p0, width=20, height=20, bg='red', highlightthickness=0)
red.grid(row=3, column=0, padx=0, pady=(5, 0), columnspan=1, sticky='ew')
correct = Label(p0, text='CORRECT', width=5, height=2,
                highlightbackground='gainsboro', bg='gainsboro')
correct.grid(row=2, column=1, columnspan=1, padx=0, pady=(25, 0), sticky='ew')
incorrect = Label(p0, text='INCORRECT', width=5, height=2,
                  highlightbackground='gainsboro', bg='gainsboro')
incorrect.grid(row=3, column=1, columnspan=1, padx=0, pady=(5, 0), sticky='ew')

# Create a progress bar
complete = 0
p = Frame(root, width=400, height=5, bg='gainsboro', highlightthickness=0)
p.grid(row=0, column=1, columnspan=1, padx=(5, 15), pady=(10, 0), sticky='nwe')
p.rowconfigure((0, 1), weight=0, uniform='foo')
style = ttk.Style()
style.theme_use('clam')
style.configure("green.Horizontal.TProgressbar", foreground='green', background='green')
progress = ttk.Progressbar(p, style="green.Horizontal.TProgressbar", orient=HORIZONTAL, length=500, mode='determinate')
progress.grid(row=0, column=0, columnspan=3, padx=(0, 7), pady=(2, 0), sticky='nw')

# Create a progress percentage label
stat = StringVar()
status = Label(p, textvariable=stat, width=5, height=1, highlightbackground='gainsboro', bg='gainsboro')
status.config(anchor='ne', pady=0)
status.grid(row=0, column=3, columnspan=1, padx=(0, 0), pady=0, sticky='nw')
stat.set('0%')

# Create a button for loading model
button_load = Button(p, text='Load Model', height=1, command=load_m, highlightbackground='gainsboro'
                     , cursor="circle")
button_load.config(anchor='nw')
button_load.grid(row=1, column=0, pady=(3, 0), padx=(0, 0), columnspan=1, sticky='nw')

# Create an entry box for user input model file path
model_input = Entry(p, bg='gainsboro')
model_input.grid(row=1, column=1, pady=(3, 0), padx=(13, 0), columnspan=1, sticky='ne')

# Create a label for model load display
mod = StringVar()
label_model = Label(p, textvariable=mod, width=20, height=1, highlightbackground='gainsboro', bg='gainsboro')
label_model.grid(row=1, column=2, columnspan=1, padx=(15, 0), pady=(3, 0), sticky='nw')
label_model.config(anchor='nw')
mod.set("-- Model: None.")

# Create a button for Evaluating model accuracy
button_eva = Button(p, text='Evaluate', height=1, width=8, command=load, highlightbackground='gainsboro'
                    , cursor="circle")
button_eva.config(anchor='nw')
button_eva.grid(row=2, column=0, pady=(20, 3), padx=(0, 0), columnspan=1, sticky='nw')

# Create a canvas to show the image during evaluation process
# canvas_display = Canvas(p, height=100, width=100, bg='gainsboro', highlightthickness=0)
# canvas_display.grid(row=2, column=1, pady=(27, 3), padx=(10, 0), columnspan=1, rowspan=10, sticky='ne')

# Create a label for model accuracy display
eva = StringVar()
evaluate = Label(p, textvariable=eva, width=26, height=1, highlightbackground='gainsboro', bg='gainsboro')
evaluate.grid(row=2, column=2, columnspan=2, padx=(15, 0), pady=(23, 3), sticky='nw')
evaluate.config(anchor='nw')

acc = StringVar()
text_acc = Label(p, textvariable=acc, width=26, height=1, highlightbackground='gainsboro', bg='gainsboro')
text_acc.grid(row=3, column=2, columnspan=2, padx=(15, 0), pady=(0, 3), sticky='nw')
text_acc.config(anchor='nw')

# Create a button to stop the evaluation process
button_eva_stop = Button(p, text='Stop', height=1, width=8, command=term, highlightbackground='gainsboro'
                         , cursor="circle")
button_eva_stop.config(anchor='nw')
button_eva_stop.grid(row=3, column=0, pady=(0, 10), padx=(0, 0), columnspan=1, sticky='nw')

# Create a canvas on the left for drawing.
canvas = Canvas(root, width=400, height=480, bg='white', highlightthickness=0)
canvas.grid(row=1, column=0, padx=(15, 5), pady=(20, 0), columnspan=1, sticky='ew')
canvas.bind('<Button-1>', activate_event)

# Create a canvas on the right for displaying prediction result.
display = Canvas(root, width=400, height=480, bg='white', highlightthickness=0)
display.grid(row=1, column=1, padx=(5, 15), pady=(20, 0), columnspan=1, sticky='ew')

# Add frame to contain buttons.
f = Frame(root, width=400, height=40, bg='gainsboro', highlightthickness=0)
f.grid(row=2, column=0, padx=(15, 5), pady=0, sticky='w', columnspan=1)
f.columnconfigure((0, 1, 2, 3), weight=1, uniform='foo')
# Add button for recognizing.
button_recognize = Button(f, text='Recognize', command=recognize_draw, highlightbackground='gainsboro', cursor="circle")
button_recognize.grid(row=0, column=0, pady=5, padx=(0, 5), columnspan=1, sticky='nw')
# Add button for clear both canvas.
button_clear = Button(f, text='Clear', command=clear, highlightbackground='gainsboro', cursor="circle")
button_clear.grid(row=0, column=1, pady=5, padx=5, columnspan=1, sticky='nw')

# Initialize and set stop signal when esc is pressed.
stop_load = 0
bsy = 0
dis_bsy = 0
root.bind('<Escape>', stop)

# Main loop for the app to run.
root.mainloop()
