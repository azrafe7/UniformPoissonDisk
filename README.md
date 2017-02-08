# UniformPoissonDisk
Uniform Poisson Disk Sampling.

<sup>[online js demo](https://cdn.rawgit.com/azrafe7/UniformPoissonDisk/master/bin/JsDemo/index.html)</sup>
<br>
![](snapshot.png)

 - supports non-uniform sampling by specifying a per-point distance function
 - a reject function can be used to filter out sampled points (while sampling)
 - optionally a first point can be specified (instead of choosing one randomly inside the sampling area)

## References

 - http://devmag.org.za/2009/05/03/poisson-disk-sampling/ (read this!)
 - http://theinstructionlimit.com/fast-uniform-poisson-disk-sampling-in-c (by Renaud Bédard)

The algorithm is from the "Fast Poisson Disk Sampling in Arbitrary Dimensions" paper by Robert Bridson
 - http://www.cs.ubc.ca/~rbridson/docs/bridson-siggraph07-poissondisk.pdf
