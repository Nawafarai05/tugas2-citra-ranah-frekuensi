function ImageOut = brightness_adjustment(Image,acale_factor)
    % Meningkatkan kecerahan dengan memanipulasi komponen DC dalam ranah
    % frekuensi
    % Input :
    %   Image   : matriks citra masukan 
    %   scale_factor: faktor pengali kecerahan
    % Output :
    %   ImageOut: matriks citra hasil (uint8)

    ImageDouble = double(Image);
    [m,n, c] = size(ImageDouble);

    % menentukan titik tengah spektrum (lokasi komponen DC)
    centre_u = floor(m/2) + 1;
    centre_v = floor(n/2) + 1;

    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        % fourier
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));

        % manipulasi komponen spekctrum tengah (pada frek 0)
        F(centre_u, centre_v) = F(centre_u, centre_v) * scale_factor;

        % inverse transformasi fourier
        ImageOut(:,:,chIdx) = real(ifft2(ifftshift(F)));
    end

    % clipping
    ImageOut = uint8(min(max(ImageOut, 0), 255));
end