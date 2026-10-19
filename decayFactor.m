function f = decayFactor(d_time)
% DECAYFACTOR Calculate the fraction of fluorine-18 activity remaining
% after radioactive decay over a specified elapsed time.
%
%   f = decayFactor(d_time)
%
% INPUT
%   d_time : Elapsed time in **minutes**. Must be a non-negative, finite,
%            real numeric scalar, vector, or array.
%
% OUTPUT
%   f      : Fraction of the initial fluorine-18 activity remaining
%            after the specified elapsed time. Values range from 0 to 1.
%            The output has the same size as d_time.
%
% METHOD
%   Radioactive decay is modelled using the exponential decay equation:
%
%       f = exp(-log(2) * d_time / T_half)
%
%   where T_half is the physical half-life of fluorine-18 (109.8 minutes).
%
%   This function returns the fraction of activity remaining, not the
%   inverse factor used to correct a measured activity back to an earlier
%   reference time. The appropriate factor depends on the correction
%   procedure being implemented.
%
% EXAMPLE
%   % Calculate the fraction of activity remaining after 10 minutes.
%   f = decayFactor(10);
%
% REFERENCE
%   Sigurdsson H, et al. NeuroImage (2024).
%   https://doi.org/10.1016/j.neuroimage.2024.120531
%
%   The reference describes the related imaging protocol. Consult the
%   publication for details of the acquisition and processing context.
%
% AUTHOR
%   Hilmar Sigurdsson
%
% VERSION
%   1.0
%
% CREATOR'S NOTE:
%
%   For our study, we rounded the half-life of fluorine-18 as
%   109.8 minutes whereas the more accurate half-life is 109.77 minutes.

    % Physical half-life of fluorine-18, in minutes.
    F18 = 109.8;

    % Validate the input.
    validateattributes(d_time, {'numeric'}, ...
        {'real', 'finite', 'nonnegative'}, ...
        mfilename, 'd_time', 1);

    % Calculate the fraction of activity remaining after radioactive decay.
    f = exp(-log(2) .* (d_time ./ F18));

end