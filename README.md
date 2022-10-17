# AudioProcess
An Audio or Signal Processing Project using Mal Frequence Cepstral Coefficient (MFCC) to recognize human speech.
Based on an assignment，a classic speech recoginition is as follows,
    1. Analyse Signal:
        - Convert Stereo to Mono
        - Plot Signal against time domain
    2. Pre-processing:
        - Find start/end point of audio: energy & zero crossing => trim
        - Analyze time-frequence: Discrete Fourier Transform => spectrum
    3. Extract Feature From Trimmed Signal:
        - Filter frequence by Mel Scale
        - (Mel Frequence) Cepstral Coeffiecient
            1. pre-emphasis (high-passing) => s'(k) = s(k) - a*s(k-1)
            2. hanning windowing (smoothing) => frames = (total - frameSize)/shift + 1
            3a. Directly calculate CC:
                - Discrete Fourier Transform => Xm
                - Logistic => Log(Xm) 
                - Inverse Discrete Fourier Transform 
                        => Cepstral Coeffiecient 
            3b. Linear Predictive Coding (Compression)
                - auto-correlation => r(k) = sum(s(i)*s(k+i))
                                    => auto-correlation matrix
                - lpc = [r1, r2, ..., rp] * inv(acm)

    4. Recognition by comparing cpestral coefficient.
        - Distortion measurement
            1. construct distortion matrix => sum( MFCC^2 )
            2. construct accumulative distortion matrix by Dynamic Program
        - Find optimal path
            1. choose optimal (smallest) value point => rightmost and top
            2. trace back from high to lower


