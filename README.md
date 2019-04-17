# CV-model-combined-with-GMM
A new algorithm to improve CV model with Gaussian Mixture Model.

## Abstract of paper
Chan-Vese(CV) model promotes the evolution of level set curve based on the gray distribution inside and outside the curve. It has a better segmentation effect on images with intensity homogeneity and obvious contrast. However, when the gray distribution of image is uneven, the evolution speed of the curve will be significantly slower, and the curve will be guided to the wrong segmentation result. To solve this problem, a method to improve CV model by using of Gaussian mixture model(GMM) is proposed. We use the parameters of the Gaussian submodels to correct the mean value of grayscale inside and outside the curve in the energy function. The target region can be quickly segmented in the images with complex background gray distribution. Experimental results show that the proposed algorithm can significantly reduce the number of iterations and enhace the robustness to noise. The level set curve can quickly evolve into target region in the images with intensity inhomogeneity.

## Direction for use
You can run Main.m to experiment and test the algorithm our project proposed with your image. You should chang fgdCompCount and bgdCompCount in the file LevelSetEvo.m to adapt to images with different gray distribution. Generally, images with a single gray distribution only need three or less submodels, while images with a complex gray distribution need more than five submodels to describe its distribution well.

## Test results
### Here is the segmentation results of level set curve driven by our model in the images with Gaussian noise.
<div align="center">
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/balls_GMM.jpg" height="220" width="180" >
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/d_GMM.jpg" height="220" width="180" >
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/plane_k25.jpg" height="220" width="180" >
</div>
### Here is the results in images with intensity inhomogeneity.
<div align="center">
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/a_GMM.jpg" height="220" width="180" >
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/c_GMM.jpg" height="220" width="180" >
<img src="https://github.com/348632874/CV-model-combined-with-GMM/blob/master/experimental%20results/noise_GMM.jpg" height="220" width="180" >
</div>
