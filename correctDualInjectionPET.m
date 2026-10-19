
function out = correctDualInjectionPET(im1, im2, f0, f1, f2, d1, d2, scaleFactor)
% CORRECTDUALINJECTIONPET Dose-correct PET images acquired using a
% dual-injection protocol.
%
%   out = correctDualInjectionPET(im1, im2, f0, f1, f2, d1, d2)
%   out = correctDualInjectionPET(..., scaleFactor)
%
% DESCRIPTION
%   The function was written for a specific purpose but may hold valuable
%   for other scenarios. In our study, we acquired two FDG-PET images in a
%   single study session, the first after the participant was standing, and 
%   the second after they were walking. Due to residual FDG activity in the
%   second scan from the first FDG injection, data underwent
%   dose-correction. 
%   The contribution of residual activity from the first
%   injection is subtracted from the second image before normalisation
%   by the second injection's decay fraction and administered dose.
%
% INPUTS
%   im1         : First PET image, after the first injection.
%
%   im2         : Second PET image, after the second injection.
%
%   f0          : Fraction of fluorine-18 activity remaining between
%                 the first and second scans. 
%                 ie calculated as exp(-ln(2)/T_half*(tscan_2 - tscan1))
%                 T_half being the radioactive half life. 
%                 Use decayFactor.m
%
%   f1          : Fraction of fluorine-18 activity remaining between
%                 the first injection and the first scan.
%
%   f2          : Fraction of fluorine-18 activity remaining between
%                 the second injection and the second scan.
%
%   d1          : Administered activity for the first injection.
%
%   d2          : Administered activity for the second injection.
%
%   scaleFactor : Optional multiplicative scaling applied to all output
%                 images. Default: 1e4, matching the scaling used in
%                 the original processing implementation.
%
%                 This factor is a numerical scaling choice; it does
%                 not itself perform a physical unit conversion.
%
% OUTPUT
%   out         : Structure containing:
%       .im1     Dose-corrected standing image.
%       .im2      Residual-tracer-corrected, dose-corrected walking image.
%       .difference Walking minus standing image.
%       .average   Mean of the corrected walking and standing images.
%
% METHOD
%   im1:
%       im1_Corrected = im1 / (f1 * d1)
%
%   im2:
%       im2_Corrected = (im2 - f0 * im1) / (f2 * d2)
%
%   Difference:
%       difference = im2_Corrected - im1_Corrected
%
%   Average:
%       average = (im2_Corrected + im1_Corrected) / 2
%
%   The scaleFactor is applied to each output.
%
% REQUIREMENTS AND ASSUMPTIONS
%   - Both images must be on the same spatial grid and aligned voxelwise.
%   - Decay fractions must be calculated using consistent timing units.
%   - Injection doses must use consistent units.
%   - The image intensities and dose units must be compatible with the
%     intended quantitative interpretation.
%   - This function does not read image files, register images, resample
%     data, or perform global intensity normalisation.
%
% REFERENCE
%   Sigurdsson H, et al. NeuroImage (2024).
%   https://doi.org/10.1016/j.neuroimage.2024.120531
%
% AUTHOR
%   Hilmar Sigurdsson
%
% VERSION
%   1.0
%

    % Default scaling used in the original implementation.
    if nargin < 8 || isempty(scaleFactor)
        scaleFactor = 1e4;
    end

    % Validate image inputs.
    validateattributes(im1, {'numeric'}, {'real', 'nonempty'}, ...
        mfilename, 'im1', 1);
    validateattributes(im2, {'numeric'}, {'real', 'nonempty'}, ...
        mfilename, 'im2', 2);

    if ~isequal(size(im1), size(im2))
        error('im1 and im2 must have identical dimensions.');
    end

    % Validate decay fractions.
    validateattributes(f0, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive', '<=', 1}, ...
        mfilename, 'f0', 3);
    validateattributes(f1, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive', '<=', 1}, ...
        mfilename, 'f1', 4);
    validateattributes(f2, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive', '<=', 1}, ...
        mfilename, 'f2', 5);

    % Validate administered activities.
    validateattributes(d1, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive'}, ...
        mfilename, 'd1', 6);
    validateattributes(d2, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive'}, ...
        mfilename, 'd2', 7);

    % Validate output scaling.
    validateattributes(scaleFactor, {'numeric'}, ...
        {'real', 'finite', 'scalar', 'positive'}, ...
        mfilename, 'scaleFactor', 8);

    % Correct the standing image for decay and administered activity.
    im1_Corrected = im1 ./ (f1 .* d1);

    % Remove the residual contribution from the first injection,
    % then correct for decay and administered activity from injection 2.
    im2_Corrected = (im2 - f0 .* im1) ./ (f2 .* d2);

    % Apply the requested numerical scaling.
    out.stand = im1_Corrected .* scaleFactor;
    out.walk = im2_Corrected .* scaleFactor;

    % Calculate the walking-minus-standing difference and their mean.
    out.difference = out.im2 - out.im1;
    out.average = (out.im2 + out.im1) ./ 2;

end
