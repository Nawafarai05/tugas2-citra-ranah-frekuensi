function ImageOut = highpass_filter(Image, type, d0, orde)
    % melakukan image sharpening / penajaman citra dalam ranah frekuensi
    % dengan mengguankan high-pass filter
    % Input :
    %   Image   : matriks citra 2D (grayscale) atau 3D (rgb)
    %   type    : ideal, gaussian, atau butterworth
    %   d0      : frekuensi cut-off (radius pita)
    %   orde       : orde filter (untuk butterworth, default = 1)
    % Ouput :
    %   ImageOut: matriks citra haisl high-pass filter (uint8)

    ImageDouble = double(Image);
    [m, n, c] = size(ImageDouble);

    if nargin < 4 || isempty(orde)
        orde = 1;
    end

    u = -floor(m/2):ceil(m/2)-1;
    v = -floor(n/2):ceil(n/2)-1;
    [V, U] = meshgrid(v, u);
    d = sqrt(U.^2 + V.^2);

    % mask H(u, v) -> kebalikan dari low-pass punya
    switch lower(type)
        case 'ideal'
            H = double(d > d0);
        case 'gaussian'
            H = 1 - exp(-(d.^2) / (2 * d0^2));
        case 'butterworth'
            H = 1 ./ (1 + (d0 ./ (d + eps)).^(2 * orde));
        otherwise
            error('Jenis filter tidak valid.');
    end

    % chIdx : channel index
    ImageOut = zeros(size(ImageDouble));
    for chIdx = 1:c
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));
        G = F .* H;
        ImageOut(:,:,chIdx) = real(ifft2(ifftshift(G)));
    end

    % clipping hasil high-pass
    ImageOut = uint8(min(max(ImageOut, 0), 255));
end