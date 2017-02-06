# UniformPoissonDisk
Uniform Poisson Disk Sampling (WIP).

<sup>[online js demo](https://cdn.rawgit.com/azrafe7/UniformPoissonDisk/master/bin/JsDemo/index.html)</sup>
<br>
![](snapshot.png)

Sampling rects and circles is already available. 
Next step is adding the possibility to customize the function used to reject/include a sample in the final result.

## References

 - http://devmag.org.za/2009/05/03/poisson-disk-sampling/
 - http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)
 - http://www.luma.co.za/labs/2008/02/27/poisson-disk-sampling/

The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
 - http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf

And with filtering ideas from:
 - https://github.com/corporateshark/poisson-disk-generator
