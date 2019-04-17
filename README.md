# CV-model-combined-with-GMM
A new algorithm to improve CV model with Gaussian Mixture Model.

## Abstract of paper
Chan-Vese(CV) model promotes the evolution of level set curve based on the gray distribution inside and outside the curve. It has a better segmentation effect on images with intensity homogeneity and obvious contrast. However, when the gray distribution of image is uneven, the evolution speed of the curve will be significantly slower, and the curve will be guided to the wrong segmentation result. To solve this problem, a method to improve CV model by using of Gaussian mixture model(GMM) is proposed. We use the parameters of the Gaussian submodels to correct the mean value of grayscale inside and outside the curve in the energy function. The target region can be quickly segmented in the images with complex background gray distribution. Experimental results show that the proposed algorithm can significantly reduce the number of iterations and enhace the robustness to noise. The level set curve can quickly evolve into target region in the images with intensity inhomogeneity.

## Direction for use
You can run Main.m to experiment and test the algorithm our project proposed with your image. You should chang fgdCompCount and bgdCompCount in the file LevelSetEvo.m to adapt to images with different gray distribution. Generally, images with a single gray distribution only need three or less submodels, while images with a complex gray distribution need more than five submodels to describe its distribution well.

## Test results
