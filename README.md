# Catmera
Catmera is an app for iPhone and iPad that predicts the breed of a cat in a photo.

## Screenshots
![Screenshots](/Assets/screenshots.png)

## Motivation
The goal of this project is pretty simple: I'm not sure what the breed of my cat is, so I wanted to create an app that could (try to) identify it for me. I also wanted to learn about two of the latest technologies from Apple, [Create ML](https://developer.apple.com/machine-learning/create-ml) and [Combine](https://developer.apple.com/documentation/combine), which enabled me to develop the app quickly and without much code.

## Technologies

- Combine
- Create ML
- PhotoKit
- Python
- SwiftUI
- UIKit
- Vision

## Creating the cat classifier
Creating and training a cat classification model with Create ML **was pretty straightforward**. What wasn't so easy was to find a dataset with which to create a decent classifier, as I'll explain now. First I had to search the Internet for image datasets of cat breeds. I found the [Cat Breeds Dataset](https://www.kaggle.com/datasets/ma7555/cat-breeds-dataset) on Kaggle, which has images of 67 cat breeds so it seemed like a perfect candidate for training the model.

After downloading the dataset I wrote [a script in Python](/CatClassifier/Scripts/generate_data_sources.py) to make it balanced in regards to the number of images per category and split it into two sets, one for training and the other for testing. Then I set out to train the model, which took around a minute... only to find out that the resulting model had a testing accuracy **of around 20 %**. What went wrong?

Having a thorough look at the data, I can see why that happened. **Its quality is questionable**, which makes sense given the fact that the images [have been obtained from an advertising platform](https://www.kaggle.com/datasets/ma7555/cat-breeds-dataset), so they're labeled by advertisers and not professionals knowledgeable about cat breeds: I'll just say there's a "Chinchilla" category, which has a couple of images of cats and one of a chinchilla 🤔

It's worth mentioning that the task the model is being trained for **might be harder than anticipated**: features don't vary _that_ much between cats compared to, for example, different species of animals. I don't expect to create a model with high accuracy, but at least I'll try.

What I did next was switch up the training settings, which in Create ML are the number of iterations and the augmentations to apply to the images, **but to no avail**, which meant that I'd be better off using another dataset. I searched again and, funnily enough, I found [the same dataset but cleared](https://www.kaggle.com/datasets/denispotapov/cat-breeds-dataset-cleared) of images that would do more harm that good, so I used my script to preprocess it and trained the model... **to end up with a low testing accuracy again**. I rapidly went through some images of this dataset and realized that, even if it had been cleared, there was still **many differences** between cats of the same category so there wasn't any point to continuing using this dataset.

Thankfully, before finding the two datasets that I've talked about, I had stumbled upon the [Cats and Dogs Breeds Classification Oxford Dataset](https://www.kaggle.com/datasets/zippyz/cats-and-dogs-breeds-classification-oxford-dataset). I didn't use it at first since it has many fewer classes than the other two, but I didn't have any choice now. I downloaded the dataset, preprocessed it with my script and added it to Create ML. For each of the 12 classes I extracted 200 images from the dataset, which I split in [160 for training](/Assets/create_ml_training_data.png) and [40 for testing](/Assets/create_ml_testing_data.png). I chose 1000 as the number of iterations, since I imagined the model would converge earlier than that, and selected Add Noise, Blur and Flip as the augmentations:
![Create ML model settings](/Assets/create_ml_model_settings.png)

The model converged early indeed, and with [a training accuracy of 100 % and a validation accuracy of 96 %](/Assets/create_ml_model_training.png), I just had to wait for a little moment to find out what the testing accuracy would be... And lo and behold...
![Create ML model evaluation](/Assets/create_ml_model_evaluation.png)

**A testing accuracy of 76 %!** I think that's pretty decent considering what happened with the other datasets. I'm sure the accuracy would be higher if it weren't for the *British Shorthair - Russian Blue problem* as I like to call it: since their features are similar, the model gets confused and the precision results of both classes are low in comparison to the others. This is an issue that may be solved by throwing more images into the mix so the model can pick up more features, but that's something for the future. The main takeaway here is that I'm very impressed with how easy and quick it was to **train a model with Create ML**. The last thing to do was to export the model and add it to the Xcode project:
![Create ML model output](/Assets/create_ml_model_output.png)

## Architecture of the app
I've developed the app using the MVVM pattern for both decoupling and organizational purposes, though there's only three views and one view model that I needed to create. The entry point of the app is `ContentView`, in which the user can choose to take a photo of a cat or pick one from their gallery in order to see a prediction of the breed of the cat. This is the view that I've created a view model for, `ContentViewModel`, which holds all logic related to the data presented to the view, but most importantly, is responsible for making the photo available to the machine learning model.

The user takes or picks a photo through `CameraView` or `PhotoPickerView`, which are `UIViewControllerRepresentable` instances of the `UIImagePickerController` and `PhotoPickerView` views provided by Apple, respectively. Both views have a binding of type `Result<UIImage?, Error>?`, which is updated when the user takes/selects a photo or if there's an error. This binding is connected through `ContentView` to its corresponding view model.

Once the view model receives a value, it either publishes an error or passes the image on to a method of the `Predictor` class, which performs an image classification request to the model that we've created on the previous section. This method returns a publisher that, once it's done, publishes a prediction or an error, which is then displayed in the view. This flow of events is implemented with **Combine**, which is really powerful once you get the grasp of it.

## Repurposing the project
It's really easy to repurpose the project for another image classification task: you just have to replace the `CatClassifier.mlmodel` file inside the Xcode project with your own model, and then adapt the design of the app to your liking.

## Room for improvement
There's a couple of things that can be improved upon:
- The first one, and the most important, is the machine learning model. What I'd do first is attempt to **create a larger dataset myself**, scraping Google Images for instance, with the purpose of increasing the accuracy of the model and making it recognize more classes. If that isn't enough, as a last resort I'd train the model with another technology other than Create ML, even if that's out of the scope of the project
- The second improvement is **making the UI _flashier_**, since that wasn't the point of the project, but it'd be great to have some animations in place to make the app look awesome

## License
Released under GPL-3.0 license. See [LICENSE](/LICENSE) for details.

## One more thing
At last, I took a picture of my cat to see what the app had to say about it...

![Cat tax](/Assets/cat_tax.png)

Guess it's settled!