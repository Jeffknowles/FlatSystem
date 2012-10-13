% FlatSystem is a Matlab application to quickly flatten digital acoustic systems.  

Jeff Knowles and Jason Gaudette

Rather than spend research dollars on top of the line acoustic systems,  one can take advantage of one ground truth receiver or emitter to flatten out any other system. 

The approach is to quickly charictorize the system with carfully designed FM stimuli and build a model filter of the sytem's frequency and phase response. One can then invert the system model and prefilter the output with the inverse filter.  As long as your analog equipment is in a linear response range, it is possible to get a perfectly flat system in a few simple steps.  

Fast moving FM stimuli allow quick charictorization across frequency, producing a transfer function for the system in magnitude and phase by frequency.  An inverse filter can cancel out all abberations relative to your ground truth receiver or emmiter. 

Steps:

1) Use the stimulus generator to produce an approriate FM sweep for the freqrency range of your system.  At most choose 0 to the neiquest frequency of the digitization.  

2) Play this stimulus and record response through the system. 

3) Input the stimulus and response waveforms into the filter generator to charactorize the system.  This function will automatically find the sweep signal on the stimulus and repsonse time series and charactorize the response, generating a low-error filter model of the system.  Save the inverse of this filter, and integrate it into your stimulus generation or sound playback system.  



