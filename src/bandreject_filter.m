function ImageOut = bandreject_filter(Image, type, d0, w, orde)
    % Mengurangi derau/noise dengan bandreject filter
    % Input:
    %   Image   : matriks citra masukan
    %   type    : ideal, gaussian, butterworth
    %   d0      : jari-jari pita pusat yang diblokir
    %   w       : lebar pita
    %   orde       : orde filter (untuk butterworth, deafult n = 1)

    ImageDouble = double(Image);
    [m, n, c] = size(ImageDouble);

    if nargin < 5 || isempty(orde)
        orde = 1
    end

    u = -floor(m/2):ceil(m/2)-1;
    v = -floor(n/2):ceil(n/2)-1;
    [V, U] = meshgrid(v, u);
    d = sqrt(U.^2 + V.^2);

    switch lower(type)
        case 'ideal'
            H = double((d < d0 - w/2) | (d > d0 + w/2));
        case 'gaussian'
            H = 1 - exp(-((d.^2 - d0^2) ./ (d .* w + eps)).^2 / 2);
        case 'butterworth'
            H = 1 ./ (1 + ((d .* w) ./ (d.^2 - d0^2 + eps)).^(2*orde));
        otherwise
            error('Jenis filter tidak valid.');
    end

    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));
        G = F .* H;
        ImageOut(:,:,chIdx) = real(ifft2(ifftshift(G)));
    end

    ImageOut = uint8(ImageOut);

end



