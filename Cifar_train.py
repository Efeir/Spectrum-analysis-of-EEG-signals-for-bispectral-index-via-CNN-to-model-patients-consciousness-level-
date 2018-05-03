# -*- coding: utf-8 -*-
'''
Created on Sun Oct 15 14:11:23 2017

@author: edison
'''
import os
os.environ["CUDA_VISIBLE_DEVICES"]="0"     #select the first GPU
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D
from keras.layers import Activation, Dropout, Flatten, Dense
from keras.callbacks import EarlyStopping
from keras import backend as K

# dimensions of our images.
img_width, img_height = 224, 224
# Early stopping. Stop training after epochs without improving on validation
conf_patience = 6

train_data_dir = 'STFT spectrum/train'
validation_data_dir = 'STFT spectrum/validation'
nb_train_samples = 8967
nb_validation_samples = 2548
epochs = 100
batch_size = 128
nb_classes = 4

if K.image_data_format() == 'channels_first':
    input_shape = (3, img_width, img_height)
else:
    input_shape = (img_width, img_height, 3)

model = Sequential()
model.add(Conv2D(32, (3, 3), input_shape=input_shape))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))

model.add(Conv2D(64, (3, 3)))
model.add(Activation('relu'))
model.add(Conv2D(64, (3, 3)))
model.add(Activation('relu'))
model.add(MaxPooling2D(pool_size=(2, 2)))

model.add(Flatten())
model.add(Dense(512))
model.add(Activation('relu'))
model.add(Dropout(0.5))
model.add(Dense(nb_classes))
model.add(Activation('softmax'))

model.compile(loss='categorical_crossentropy',
              optimizer='adam',
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

callbacks = [
        EarlyStopping(monitor='val_loss', patience=conf_patience, verbose=0),
        # ModelCheckpoint('best.hdf5', monitor='val_loss', save_best_only=True, verbose=0),
    ]
    
model.fit_generator(
    train_generator,
    steps_per_epoch=nb_train_samples // batch_size,
    epochs=epochs,
    validation_data=validation_generator,
    validation_steps=nb_validation_samples // batch_size)#,
#   verbose=1,
#    callbacks=callbacks)

model.save_weights('STFT_Spec_cifar.h5')
