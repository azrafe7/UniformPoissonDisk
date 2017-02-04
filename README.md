# UniformPoissonDisk
Uniform Poisson Disk Sampling (WIP).

<sup>[online js demo](https://cdn.rawgit.com/azrafe7/UniformPoissonDisk/master/bin/JsDemo/index.html)</sup>
<br>
![](snapshot.png)

Sampling rects and circles is already available. 
Next step is adding the possibility to customize the function used to reject/include a sample in the final result.

## References

 - http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)
 
Which in turn is:

- Adapted from java source by Herman Tulleken
    http://www.luma.co.za/labs/2008/02/27/poisson-disk-sampling/

- The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
    http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
