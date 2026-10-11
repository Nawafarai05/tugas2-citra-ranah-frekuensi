function ImageOut = notch_reject_filter(Image, type, uk, vk, d0, orde)
    % Mengurangi derau periodik menggunakan Notch Reject Filter
    % Input:
    %   Image   : matriks citra masukan
    %   type    : 'ideal', 'gaussian', atau 'butterworth'
    %   uk, vk  : pergeseran pusat derau dari titik tengah spektrum
    %   d0      : radius pemotongan (seberapa besar titik derau yang diblokir)
    %   orde    : orde filter (untuk butterworth, default n = 1)
    
    ImageDouble = double(Image);
    [m, n, c] = size(ImageDouble);
    
    if nargin < 6 || isempty(orde)
        orde = 1;
    end
    
    u = -floor(m/2):ceil(m/2)-1;
    v = -floor(n/2):ceil(n/2)-1;
    [V, U] = meshgrid(v, u);
    
    % jarak dari titik (uk, vk) dan titik simetrisnya (-uk, -vk)
    D1 = sqrt((U - uk).^2 + (V - vk).^2);
    D2 = sqrt((U + uk).^2 + (V + vk).^2);
    
    switch lower(type)
        case 'ideal'
            H1 = double(D1 > d0);
            H2 = double(D2 > d0);
            H = H1 .* H2;
        case 'gaussian'
            H1 = 1 - exp(-(D1.^2) / (2 * d0^2));
            H2 = 1 - exp(-(D2.^2) / (2 * d0^2));
            H = H1 .* H2;
        case 'butterworth'
            H1 = 1 ./ (1 + (d0 ./ (D1 + eps)).^(2 * orde));
            H2 = 1 ./ (1 + (d0 ./ (D2 + eps)).^(2 * orde));
            H = H1 .* H2;
        otherwise
            error('Jenis filter tidak valid.');
    end
    
    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));
        G = F .* H;
        ImageOut(:,:,chIdx) = real(ifft2(ifftshift(G)));
    end
    
    ImageOut = uint8(min(max(ImageOut, 0), 255));
end