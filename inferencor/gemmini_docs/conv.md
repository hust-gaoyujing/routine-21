scale_factor：

>   h=(data_lowlight.shape[0]//scale_factor)*scale_factor
>
>   w=(data_lowlight.shape[1]//scale_factor)*scale_factor

原始图像的长和宽缩放，这个过程是如何实现，其中的像素点如何处理？

相应的经过卷积之后需要做线性插值，什么原理，能否硬件加速，还是直接使用CPU处理，对CPU有什么要求（FPU？DSP？），Rocket的核能否完成。





内存要求：

**BCNN（硬件版）：**

虚数生成：(2∗3+1∗1∗3∗3)∗2=30(2∗3+1∗1∗3∗3)∗2=30

conv1:3∗3∗6∗6+6+1∗1∗6∗64+64=7723∗3∗6∗6+6+1∗1∗6∗64+64=772

conv2:(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704

conv3:(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704

conv4:(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704(3∗3∗32∗32∗2+1∗1∗32∗32∗2)/32+2∗32=704

conv5:(3∗3∗64∗64∗2+1∗1∗64∗32∗2)/32+2∗32=2496(3∗3∗64∗64∗2+1∗1∗64∗32∗2)/32+2∗32=2496

conv6:(3∗3∗64∗64∗2+1∗1∗64∗32∗2)/32+2∗32=2496(3∗3∗64∗64∗2+1∗1∗64∗32∗2)/32+2∗32=2496

conv7:3∗3∗128∗128+128+1∗1∗128∗3+3=1479713∗3∗128∗128+128+1∗1∗128∗3+3=147971

new_conv7:3∗3∗128∗32+32+1∗1∗32∗3+3=369953∗3∗128∗32+32+1∗1∗32∗3+3=36995

总计：155,877155,877 新版：44,901

44901 -> 176kB   至少预留190kB内存



原图与中间缓存：

- 以`512*512*3`的图片为例，原图需要占用内存为：

$$
512*512*3 = 786,432\ B= 768\ kB
$$

- 前3个conv过程的输出都是64通道（实部虚部分别32通道）的`512*512*1`的数据，且均需要保存与后续3个conv结果进行cat后作为输入。

  - 每个conv过程又分为Conv2D(3x3)与Conv2D（1x1)，对于Conv2D(3x3)，conv1层的输入和输出为`512*512*3*2` float32；conv2~4层的输入和输出为`512*512*32*2` bits；conv5~6层的输入和输出均为`512*512*64*2` bits；conv7层的输入为`512*512*128` float32（从上层输出进入该层输入的数据需要进行处理），输出为`512*512*32` float32；

  - 对于Conv2D(1x1)，conv1层的输入为`512*512*3*2` float32，输出为`512*512*32*2` bits;conv2~4层的输入和输出均为`512*512*32*2` bits；conv5~6层的输入为`512*512*64*2` bits，输出为`512*512*32*2` bits，conv7层的输入为`512*512*32` float32，输出为`512*512*3` float32；

  - conv1~4的中间缓存和输出所需内存均为：
    $$
    512*512*32*2\ bits=2048\ kB = 2\ MB
    $$

  - conv5~6的中间缓存：
    $$
    512*512*64*2\ bits=4096\ kB = 4\ MB
    $$
    输出所需内存:
    $$
    512*512*32*2\ bits=2048\ kB = 2\ MB
    $$

  - conv7的中间缓存：
    $$
    512*512*32*32\ bits= 262144\ kB = 256\ MB
    $$
    输出内存：
    $$
    512*512*3*32\ bits= 24576\ kB = 24\ MB
    $$
    







数据cat硬件实现：