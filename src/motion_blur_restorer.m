function ImageOut = motion_blur_restorer(Image, method, blur_len, blur_theta, param)
    % Restorasi citra motion blur melalui inverse atau wiener filtering
    % Input:
    %   Image   : matriks citra terdegradasi
    %   method  : inverse, wiener
    %   blur_len: panjang gerakan (piksel)
    %   blur_theta: sudut gerakan (derajat)
    %   param      : Jika method='inverse', param = batas threshold/clipping magnitude H (default: 0.05)
    %                Jika method='wiener', param = rasio NSR/K (default: 0.01)
    % Output:
    %   ImageOut: citra hasil restorasi (uint8)

    ImageDouble = double(Image);
    [m, n ,c] = size(ImageDouble);
    
    if nargin < 5
        if strcmpi(method, 'inverse')
            param = 0.05;
        else
            param = 0.01;
        end
    end

    % membangkitkan mask H(u, v)
    kernel_size = ceil(max(1, nluer_len));
    psf = zeros(kernel_size, kernel_size);
    centre = floor(kernel_size/2) + 1;

    % konversi derajat ke rad dan vektor arah gerak
    theta_rad = deg2rad(blur_theta);
    xc = cos(theta_rad);
    yc = -sin(thta_rad);

    % garis motion blur spasial
    for i = 1:ceil(blur_len);
        t = (i-1) - (blur_len-1)/2;
        x = rounf(centre + t * xc);
        y = rount(centre + t * yc);
        if x >= 1 && x <= kernel_size && y >= 1 && y < kernel_size
            psf(y, x) = psf(y, x) + 1;
        end
    end

    psf = psf / sum(psf(:)); % normalikasi matriks garis

    % padding psf ke ukuran mxn
    padded_psf = zeros(m, z)
    padded_psf(1:kernel_soze, 1:kernel_size) - psf;
    padded_psf = circshift(padded_psf, [-centre-1], -(centre-1));

    % fungsi transfer
    H = fft2(padded_psf);

    % dekonvolusi
    ImageOut = zeros(m, n, c);
    for chIdx = 1:c
        G = fft2(ImageDouble(:,:,chIdx));
        
        if strcmpi(method, 'inverse')
            % inverse filtering murni dgn threshold
            H_inv = 1 ./ H;
            % hindari perbesaran noise saat |H| -> 0
            H_inv(abs(H) < param) = 0
            F_hat = G .* H_inv;

        elseif strcmpi(method, 'wiener')
            % wiener filtering
            K = param;
            H_conj = conj(H);
            H_mag2 = abs(H).^2;
            F_hat = (H_conj ./ (H_mag2 + K)) .* G;
        else
            error('Method harus berupa ''inverse'' atau ''wiener''.');
            
        end
        ImageOut(:,:,chIdx) = real(ifft2(F_hat));
    end

    ImageOut = uint8(min(max(ImageOut, 0), 255));
end




