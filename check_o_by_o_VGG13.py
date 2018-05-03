# -*- coding: utf-8 -*-
"""
Created on Sun Oct 15 20:23:42 2017

@author: edison
"""


import os
os.environ["CUDA_VISIBLE_DEVICES"]="0"     #select the first GPU
import numpy as np
from keras.preprocessing import image
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Sequential
from keras.layers import Conv2D, MaxPooling2D
from keras.layers import Activation, Dropout, Flatten, Dense
from keras.callbacks import EarlyStopping, ModelCheckpoint
from keras import backend as K

# dimensions of our images.
img_width, img_height = 224, 224

nb_classes = 4

def loadmodel(model_name):
    if K.image_data_format() == 'channels_first':
        input_shape = (3, img_width, img_height)
#        print('flag=0')
    else:
        input_shape = (img_width, img_height, 3)
#        print('flag=1')
    
    model = Sequential()
	model.add(Conv2D(64, (3, 3), input_shape=input_shape))
	model.add(Activation('relu'))
	model.add(Conv2D(64, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size=(2, 2)))
	
	model.add(Conv2D(128, (3, 3)))
	model.add(Activation('relu'))
	model.add(Conv2D(128, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size=(2, 2)))
	
	#model.add(Conv2D(256, (3, 3)))
	#model.add(Activation('relu'))
	model.add(Conv2D(256, (3, 3)))
	model.add(Activation('relu'))
	model.add(Conv2D(256, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size=(2, 2)))
	
	#model.add(Conv2D(512, (3, 3)))
	#model.add(Activation('relu'))
	model.add(Conv2D(512, (3, 3)))
	model.add(Activation('relu'))
	model.add(Conv2D(512, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size=(2, 2)))
	
	#model.add(Conv2D(512, (3, 3)))
	#model.add(Activation('relu'))
	model.add(Conv2D(512, (3, 3)))
	model.add(Activation('relu'))
	model.add(Conv2D(512, (3, 3)))
	model.add(Activation('relu'))
	model.add(MaxPooling2D(pool_size=(2, 2)))

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

    model.load_weights(model_name)
    return model

def saveastxt(filename,content):
  
    file = open(filename,mode='a')
    for i in range(len(content)):
        file.write(str(content[i])+' ')
    file.write('\n')
    file.close()

# ===========  杈撳叆璁剧疆  =========
model=loadmodel('STFT_Spec_VGG13.h5')
class_label=["Deep_35_41", "Shallow_42_64", "Unnomal", "awake_65_100"]
path_all=['K_fold_cross_1']
for path0 in path_all:
    train_dir = path0 + '/train'
    validation_dir = path0 + '/validation'
    test_dir = path0 + '/test'
    tvt = [train_dir,validation_dir,test_dir]
    for path1 in tvt:
        content0 = [path1+':']
        saveastxt('VGG13_OneByOne_prediction.txt',content0)
        for eval_class in class_label:
            class_dir = path1+'/'+ eval_class +'/'
            all_pics = (os.listdir(class_dir))
            ptm =[]
            for ap in range(len(all_pics)):
                img_path = class_dir + all_pics[ap]
                img = image.load_img(img_path, target_size=(224, 224))
                x = image.img_to_array(img)
                x = np.expand_dims(x, axis=0)
                preds = model.predict(x)
                pred_max = np.argmax(preds)
                ptm.append(pred_max)
            #print(ptm)
            s_0 = 0;s_1 = 0;s_2 = 0;s_3 = 0;
            
            for si in range(len(ptm)):
                if ptm[si] == 0:
                    s_0 = s_0 + 1
                elif ptm[si] == 1:
                    s_1 = s_1 + 1
                elif ptm[si] == 2:
                    s_2 = s_2 + 1
                elif ptm[si] == 3:
                    s_3 = s_3 + 1
            #print(s_0,s_1,s_2,s_3)
            content = ['    '+eval_class+':',s_0,s_1,s_2,s_3]
            saveastxt('VGG13_OneByOne_prediction.txt',content)

