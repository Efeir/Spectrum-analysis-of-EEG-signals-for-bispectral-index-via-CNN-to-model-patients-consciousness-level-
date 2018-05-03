import os
os.environ["CUDA_VISIBLE_DEVICES"]="0"     #select the first GPU
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D
from keras.layers import Activation, Dropout, Flatten, Dense
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras import backend as K

# dimensions of our images.
img_width, img_height = 227, 227
# Early stopping. Stop training after epochs without improving on validation
conf_patience = 6

train_data_dir = 'K_fold_cross_10/train'
validation_data_dir = 'K_fold_cross_10/validation'
nb_train_samples = 8059
nb_validation_samples = 2303
epochs = 70
batch_size = 128
nb_classes = 4

if K.image_data_format() == 'channels_first':
    input_shape = (3, img_width, img_height)
else:
    input_shape = (img_width, img_height, 3)

model = Sequential()
model.add(Conv2D(96, (11, 11), strides=4, input_shape=input_shape))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(3, 3),strides=2))

model.add(Conv2D(256, (5, 5)))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(3, 3),strides=2))

model.add(Conv2D(384, (3, 3)))
model.add(Activation('relu'))
model.add(Conv2D(384, (3, 3)))
model.add(Activation('relu'))
model.add(Conv2D(256, (3, 3)))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(3, 3),strides=2))

model.add(Flatten())
model.add(Dense(4096))
model.add(Activation('tanh'))
model.add(Dropout(0.5))
model.add(Dense(4096))
model.add(Activation('tanh'))
model.add(Dropout(0.5))
model.add(Dense(nb_classes))
model.add(Activation('softmax'))
# adadelta矛adam
model.compile(loss='categorical_crossentropy',
              optimizer='adadelta',
              metrics=['accuracy'])
              
# this is the augmentation configuration we will use for training
train_datagen = ImageDataGenerator(
    rescale=1. / 255,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True)

# this is the augmentation configuration we will use for testing:
# only rescaling
test_datagen = ImageDataGenerator(rescale=1. / 255)

train_generator = train_datagen.flow_from_directory(
    train_data_dir,
    target_size=(img_width, img_height),
    batch_size=batch_size,
    class_mode='categorical')

validation_generator = test_datagen.flow_from_directory(
    validation_data_dir,
    target_size=(img_width, img_height),
    batch_size=batch_size,
    class_mode='categorical')
filepath="./K_fold_cross_10/epoch_{epoch:02d}-val_acc_{val_acc:.2f}.hdf5"
callbacks = [
        #EarlyStopping(monitor='val_loss', patience=conf_patience, verbose=0),
        ModelCheckpoint(filepath, monitor='val_loss', verbose=0),
    ]

model.fit_generator(
    train_generator,
    steps_per_epoch=nb_train_samples // batch_size,
    epochs=epochs,
    validation_data=validation_generator,
    validation_steps=nb_validation_samples // batch_size,
    verbose=1,
    callbacks=callbacks)

model.save_weights('K_fold_cross_10/STFT_spec_AlexNet.hdf5')
