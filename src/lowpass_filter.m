function ImageOut = lowpass_filter(Image, type, d0, orde)
    % Melakukan image smoothing dalam ranah frekuensi menggunakan lowpass
    % filter (dengan berbagai tipe)
    % Input : 
    %   Image   : matriks citra 2D (grayscale) atau 3D (berwarna)
    %   type    : ideal, gaussian, atau butterworth
    %   d0      : frekuensi cut-off (radius pita)
    %   orde       : orde filter (untuk butterworth, deafult = 1)
    % Output :
    %    ImageOut: matriks citra haisl smoothing (uint8)
    
    ImageDouble = double(Image);
    [m, n, c] = size(ImageDouble);
    
    if nargin < 4 || isempty(orde)
        orde = 1;
    end
    
    % grid freq u dna v
    u = -floor(m/2):ceil(m/2)-1;
    v = -floor(n/2):ceil(n/2)-1;
    [V, U] = meshgrid(v, u);
    d = sqrt(U.^2 + V.^2);
    
    % mask H(u, v)
    switch lower(type)
        case 'ideal'
            H = double(d <= d0);
        case 'gaussian'
            H = exp(-(d.^2) / (2 * d0^2));
        case 'butterworth'
            H = 1 ./ (1 + (d ./ d0).^(2 * orde));
        otherwise
            error('Tipe filter tidak valid.');
    end
    
    % pemrosesan tiap channel (grayscale maupun rgb)
    % chIdx : channel index
    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        % fft terpusat
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));
        % penapisan
        G = H .* F;
        % inverse fft    
        filteredChannel = real(ifft2(ifftshift(G)));
        ImageOut(:, :, chIdx) = filteredChannel;
    end
    
    ImageOut = uint8(min(max(ImageOut, 0), 255));
end
