function ImageOut = brightness_adjustment(Image, scale_factor)
    % Meningkatkan kecerahan dengan memanipulasi komponen DC dalam ranah
    % frekuensi
    % Input :
    %   Image   : matriks citra masukan 
    %   scale_factor: faktor pengali kecerahan
    % Output :
    %   ImageOut: matriks citra hasil (uint8)

    ImageDouble = double(Image);
    [m, n, c] = size(ImageDouble);

    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        % fourier
        F = fftshift(fft2(ImageDouble(:,:,chIdx)));

        % manipulasi komponen spekctrum tengah (pada frek 0)
        F = F * scale_factor;

        % inverse transformasi fourier
        ImageOut(:,:,chIdx) = real(ifft2(ifftshift(F)));
    end

    % clipping
    ImageOut = uint8(min(max(ImageOut, 0), 255));
end