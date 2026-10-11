function mainGUI()
    % PATH DAN INISIALISASI VARIABEL UTAMA
    addpath(genpath('src'));
    addpath(genpath('02_citra_test_images'));

    appData = struct();
    appData.originalImg = [];
    appData.imgHistory  = {}; 
    appData.histData    = {}; 
    appData.maskHistory = {}; 
    appData.is3Ch       = false;
    appData.isGrayscale = true;
    appData.baseDir     = '02_citra_test_images'; 
    appData.saveDir     = 'result_images'; % Folder penyimpanan hasil restorasi

    % INISIALISASI MAIN WINDOW
    fig = figure('Name', 'Tugas 2 IF4073 - Pemrosesan Citra Ranah Frekuensi', ...
                 'NumberTitle', 'off', 'MenuBar', 'none', 'Resize', 'off', ...
                 'Position', [50, 50, 1320, 680]);

    % PANEL INPUT, PARAMETER, DAN STATISTIK
    pnlLeft = uipanel('Parent', fig, 'Title', 'Panel Kontrol & Analisis', ...
                      'FontWeight', 'bold', 'Units', 'pixels', 'Position', [10, 10, 420, 660]);

    % Input Citra
    pnlImg = uipanel('Parent', pnlLeft, 'Title', 'Input Citra', ...
                     'FontWeight', 'bold', 'Units', 'pixels', 'Position', [10, 556, 400, 88]);

    uicontrol('Parent', pnlImg, 'Style', 'text', 'String', 'Folder:', 'HorizontalAlignment', 'left', 'Position', [10, 42, 50, 20]);
    popFolder = uicontrol('Parent', pnlImg, 'Style', 'popupmenu', 'String', {'-'}, 'Position', [65, 40, 325, 25]);
    uicontrol('Parent', pnlImg, 'Style', 'text', 'String', 'File:', 'HorizontalAlignment', 'left', 'Position', [10, 12, 50, 20]);
    popFile = uicontrol('Parent', pnlImg, 'Style', 'popupmenu', 'String', {'-'}, 'Position', [65, 10, 235, 25]);
    
    set(popFolder, 'Callback', @(~,~) updateFileDropdown(popFolder, popFile));
    uicontrol('Parent', pnlImg, 'Style', 'pushbutton', 'String', 'Muat', 'FontWeight', 'bold', 'Position', [310, 10, 80, 25], 'Callback', @(~,~) loadImage());

    % Metode dan Parameter
    pnlMeth = uipanel('Parent', pnlLeft, 'Title', 'Metode dan Parameter Frekuensi', ...
                      'FontWeight', 'bold', 'Units', 'pixels', 'Position', [10, 240, 400, 308]);

    uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Metode:', 'HorizontalAlignment', 'left', 'Position', [10, 260, 50, 20]);
    
    metodeList = {'Low-Pass Filter (Smoothing)', 'High-Pass Filter (Sharpening)', ...
                  'Peningkatan Kecerahan (Brightness Adjustment)', 'Restorasi Derau Periodik (Bandreject Filter)', 'Restorasi Motion Blur'};
              
    popMethod = uicontrol('Parent', pnlMeth, 'Style', 'popupmenu', ...
                          'String', metodeList, 'Value', 1, 'Position', [65, 258, 325, 25], 'Callback', @methodChanged);
                      
    % KOLOM INPUT PARAMETER DINAMIS
    % 1. LPF / HPF / Bandreject Filters (Group 1)
    txtType1 = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Tipe Filter:', 'HorizontalAlignment', 'left', 'Position', [10, 210, 100, 20], 'Visible', 'off');
    popType1 = uicontrol('Parent', pnlMeth, 'Style', 'popupmenu', 'String', {'Ideal', 'Gaussian', 'Butterworth'}, 'Position', [115, 208, 275, 25], 'Visible', 'off');
    
    txtD0 = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Cut-off (D0):', 'HorizontalAlignment', 'left', 'Position', [10, 178, 100, 20], 'Visible', 'off');
    editD0 = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '50', 'Position', [115, 178, 275, 22], 'Visible', 'off');
    
    txtW = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Lebar Pita (W):', 'HorizontalAlignment', 'left', 'Position', [10, 146, 100, 20], 'Visible', 'off');
    editW = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '10', 'Position', [115, 146, 275, 22], 'Visible', 'off');
    
    txtN = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Orde (n):', 'HorizontalAlignment', 'left', 'Position', [10, 114, 100, 20], 'Visible', 'off');
    editN = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '2', 'Position', [115, 114, 275, 22], 'Visible', 'off');
    
    groupFilters = [txtType1, popType1, txtD0, editD0, txtN, editN];
    groupBandreject = [txtW, editW]; 

    % 2. Peningkatan Kecerahan
    txtScale = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Skala DC (F(0,0)):', 'HorizontalAlignment', 'left', 'Position', [10, 210, 100, 20], 'Visible', 'off');
    editScale = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '1.5', 'Position', [115, 210, 275, 22], 'Visible', 'off');
    
    groupBrightness = [txtScale, editScale];

    % 3. Motion Blur
    txtTypeMB = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Metode Restorasi:', 'HorizontalAlignment', 'left', 'Position', [10, 210, 100, 20], 'Visible', 'off');
    popTypeMB = uicontrol('Parent', pnlMeth, 'Style', 'popupmenu', 'String', {'Inverse Filtering', 'Wiener Filtering'}, 'Position', [115, 208, 275, 25], 'Visible', 'off');
    
    txtLen = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Length (Piksel):', 'HorizontalAlignment', 'left', 'Position', [10, 178, 100, 20], 'Visible', 'off');
    editLen = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '21', 'Position', [115, 178, 275, 22], 'Visible', 'off');
    
    txtTheta = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Theta (Derajat):', 'HorizontalAlignment', 'left', 'Position', [10, 146, 100, 20], 'Visible', 'off');
    editTheta = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '11', 'Position', [115, 146, 275, 22], 'Visible', 'off');
    
    txtParamMB = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Threshold / K:', 'HorizontalAlignment', 'left', 'Position', [10, 114, 100, 20], 'Visible', 'off');
    editParamMB = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '0.01', 'Position', [115, 114, 275, 22], 'Visible', 'off');
    
    groupMB = [txtTypeMB, popTypeMB, txtLen, editLen, txtTheta, editTheta, txtParamMB, editParamMB];

    % Tombol Eksekusi dan Simpan
    btnProcess  = uicontrol('Parent', pnlMeth, 'Style', 'pushbutton', 'String', 'Terapkan', 'FontWeight', 'bold', 'BackgroundColor', [0.15 0.55 0.25], 'ForegroundColor', 'white', 'Position', [10, 12, 90, 32], 'Callback', @(~,~) processImage());
    btnUndo     = uicontrol('Parent', pnlMeth, 'Style', 'pushbutton', 'String', 'Undo', 'FontWeight', 'bold', 'BackgroundColor', [0.9 0.6 0.1], 'Position', [105, 12, 80, 32], 'Callback', @(~,~) undoImage());
    btnReset    = uicontrol('Parent', pnlMeth, 'Style', 'pushbutton', 'String', 'Reset', 'FontWeight', 'bold', 'BackgroundColor', [0.75 0.2 0.2], 'ForegroundColor', 'white', 'Position', [190, 12, 80, 32], 'Callback', @(~,~) resetImage());
    btnDownload = uicontrol('Parent', pnlMeth, 'Style', 'pushbutton', 'String', 'Simpan Hasil', 'FontWeight', 'bold', 'BackgroundColor', [0.1 0.4 0.6], 'ForegroundColor', 'white', 'Position', [275, 12, 115, 32], 'Callback', @(~,~) downloadImage());

    % INFORMASI CITRA DAN RIWAYAT
    pnlStatus = uipanel('Parent', pnlLeft, 'Title', 'Informasi dan Riwayat Analisis', 'FontWeight', 'bold', 'Units', 'pixels', 'Position', [10, 10, 400, 220]);
    lblFileInfo = uicontrol('Parent', pnlStatus, 'Style', 'text', 'String', 'File: -', 'HorizontalAlignment', 'left', 'FontWeight', 'bold', 'Position', [10, 175, 380, 18], 'BackgroundColor', [0.94 0.94 0.94]);
    tblHistory = uitable('Parent', pnlStatus, 'ColumnName', {'Metode', 'Parameter'}, 'ColumnWidth', {140, 220}, 'RowName', [], 'Position', [6, 6, 386, 160]);

    % VISUALISASI 4 KUADRAN
    pnlRight = uipanel('Parent', fig, 'Title', 'Visualisasi Frekuensi dan Spasial', 'FontWeight', 'bold', 'Units', 'pixels', 'Position', [440, 10, 870, 660]);

    axInImg   = axes('Parent', pnlRight, 'Position', [0.05, 0.55, 0.40, 0.40]); title(axInImg, 'Citra Masukan / Terdegradasi');
    axInSpec  = axes('Parent', pnlRight, 'Position', [0.55, 0.55, 0.40, 0.40]); title(axInSpec, 'Spektrum Frekuensi Masukan');
    axMask    = axes('Parent', pnlRight, 'Position', [0.05, 0.08, 0.40, 0.40]); title(axMask, 'Mask Penapis / H(u,v)');
    axOutImg  = axes('Parent', pnlRight, 'Position', [0.55, 0.08, 0.40, 0.40]); title(axOutImg, 'Citra Hasil Restorasi / Filter');
    
    axis([axInImg axInSpec axMask axOutImg], 'off');
    
    set([btnProcess, btnUndo, btnReset, btnDownload], 'Enable', 'off');
    refreshDirectories();

    % FUNGSI PEMBANTU GUI
    function refreshDirectories()
        if ~exist(appData.baseDir, 'dir'), mkdir(appData.baseDir); end
        d = dir(appData.baseDir);
        isSub = [d(:).isdir]; fldNames = {d(isSub).name}';
        fldNames(ismember(fldNames,{'.','..'})) = [];
        if isempty(fldNames), fldNames = {'(Kosong)'}; end
        set(popFolder, 'String', fldNames, 'Value', 1);
        updateFileDropdown(popFolder, popFile);
    end
    
    function updateFileDropdown(popFld, popFil)
        flds = get(popFld, 'String'); selFld = flds{get(popFld, 'Value')};
        if strcmp(selFld, '(Kosong)'), set(popFil, 'String', {'-'}, 'Value', 1); return; end
        
        % Pencarian file difokuskan pada subfolder 'input' berdasarkan struktur spesifikasi
        targetDir = fullfile(appData.baseDir, selFld, 'input');
        if ~exist(targetDir, 'dir')
            targetDir = fullfile(appData.baseDir, selFld); % Fallback jika 'input' tidak ada
        end
        
        f = dir(fullfile(targetDir, '*.*'));
        fNames = {f(~[f.isdir]).name}'; fNames = fNames(~startsWith(fNames, '.'));
        if isempty(fNames), fNames = {'(Kosong)'}; end
        set(popFil, 'String', fNames, 'Value', 1);
    end

    function methodChanged(~, ~)
        val = get(popMethod, 'Value');
        set(groupFilters, 'Visible', 'off');
        set(groupBandreject, 'Visible', 'off');
        set(groupBrightness, 'Visible', 'off');
        set(groupMB, 'Visible', 'off');
        
        if val == 1 || val == 2 % LPF / HPF
            set(groupFilters, 'Visible', 'on');
        elseif val == 3 % Brightness
            set(groupBrightness, 'Visible', 'on');
        elseif val == 4 % Periodic Noise (Bandreject)
            set(groupFilters, 'Visible', 'on');
            set(groupBandreject, 'Visible', 'on');
        elseif val == 5 % Motion Blur
            set(groupMB, 'Visible', 'on');
        end
    end

    function loadImage()
        folders = get(popFolder, 'String'); folderSelected = folders{get(popFolder, 'Value')};
        files = get(popFile, 'String'); fileSelected = files{get(popFile, 'Value')};
        if strcmp(folderSelected, '(Kosong)') || strcmp(fileSelected, '(Kosong)'), return; end
        
        targetDir = fullfile(appData.baseDir, folderSelected, 'input');
        if ~exist(targetDir, 'dir'), targetDir = fullfile(appData.baseDir, folderSelected); end
        
        imgPath = fullfile(targetDir, fileSelected);
        if ~exist(imgPath, 'file'), errordlg('File tidak ditemukan!'); return; end

        img = imread(imgPath);
        appData.originalImg = img;
        appData.imgHistory  = {img};
        appData.maskHistory = {zeros(size(img,1), size(img,2))};
        appData.histData = {'Citra Masukan Awal', '-'};
        
        set(lblFileInfo, 'String', ['File: ', fileSelected]);
        set([btnProcess, btnReset], 'Enable', 'on');
        set([btnUndo, btnDownload], 'Enable', 'off');
        methodChanged(); 
        updateVisuals();
    end

    % FUNGSI PEMROSESAN UTAMA
    function processImage()
        imgIn = appData.imgHistory{end}; 
        metodeVal = get(popMethod, 'Value');
        
        [M, N, C] = size(imgIn);
        imgOut = zeros(M, N, C, 'uint8');
        paramStr = '';
        H_disp = ones(M, N); 

        try
            % 1. Low-Pass Filter
            if metodeVal == 1 
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); n = str2double(get(editN, 'String'));
                
                imgOut = lowpass_filter(imgIn, fType, D0, n);
                paramStr = sprintf('LPF %s, D0=%g, n=%g', fType, D0, n);
                H_disp = generate_lpf_mask(M, N, fType, D0, n);
                
            % 2. High-Pass Filter
            elseif metodeVal == 2
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); n = str2double(get(editN, 'String'));
                
                imgOut = highpass_filter(imgIn, fType, D0, n);
                paramStr = sprintf('HPF %s, D0=%g, n=%g', fType, D0, n);
                H_disp = 1 - generate_lpf_mask(M, N, fType, D0, n); 
                
            % 3. Peningkatan Kecerahan
            elseif metodeVal == 3
                scaleF = str2double(get(editScale, 'String'));
                
                imgOut = brightness_adjustment(imgIn, scaleF);
                paramStr = sprintf('Scale DC = %g', scaleF);
                H_disp = zeros(M, N); H_disp(floor(M/2)+1, floor(N/2)+1) = 1; 
                
            % 4. Bandreject Filter
            elseif metodeVal == 4
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); W = str2double(get(editW, 'String'));
                n = str2double(get(editN, 'String'));
                
                imgOut = bandreject_filter(imgIn, fType, D0, W, n);
                paramStr = sprintf('BRF %s, D0=%g, W=%g', fType, D0, W);
                H_disp = generate_bandreject_mask(M, N, fType, D0, W, n);
                
            % 5. Motion Blur Restoration
            elseif metodeVal == 5
                opts = get(popTypeMB, 'String');
                metodeRaw = lower(opts{get(popTypeMB, 'Value')});
                if contains(metodeRaw, 'inverse'), fType = 'inverse'; else, fType = 'wiener'; end
                
                len = str2double(get(editLen, 'String'));
                theta = str2double(get(editTheta, 'String'));
                param = str2double(get(editParamMB, 'String'));
                
                imgOut = motion_blur_restorer(imgIn, fType, len, theta, param);
                paramStr = sprintf('%s, L=%g, T=%g, P=%g', upper(fType), len, theta, param);
                H_disp = generate_motion_blur_psf(M, N, len, theta); 
            end
            
        catch ME
            errordlg(ME.message, 'Error Pemrosesan'); return;
        end

        appData.imgHistory{end+1} = imgOut;
        appData.maskHistory{end+1} = H_disp;
        metodeList = get(popMethod, 'String');
        namaMetode = metodeList{metodeVal};
        appData.histData(end+1, :) = {namaMetode, paramStr};
        
        set([btnUndo, btnDownload], 'Enable', 'on');
        updateVisuals();
    end

    % FUNGSI MENYIMPAN CITRA HASIL
    function downloadImage()
        if length(appData.imgHistory) < 2, return; end
        
        prompt = {'Masukkan nama file (tanpa ekstensi .png):'};
        dlgtitle = 'Simpan Citra Restorasi';
        dims = [1 50];
        definput = {'hasil_restorasi'};
        answer = inputdlg(prompt, dlgtitle, dims, definput);
        
        if isempty(answer), return; end
        
        fileName = [answer{1}, '.png'];
        if ~exist(appData.saveDir, 'dir'), mkdir(appData.saveDir); end
        
        fullPath = fullfile(appData.saveDir, fileName);
        try
            imwrite(appData.imgHistory{end}, fullPath);
            msgbox(['Berhasil menyimpan citra di: ', fullPath], 'Sukses Menyimpan');
        catch ME
            errordlg(['Gagal menyimpan citra: ', ME.message], 'Error Menyimpan');
        end
    end

    function undoImage()
        if length(appData.imgHistory) > 1
            appData.imgHistory(end) = [];
            appData.maskHistory(end) = [];
            appData.histData(end, :) = [];
            if length(appData.imgHistory) == 1
                set([btnUndo, btnDownload], 'Enable', 'off'); 
            end
            updateVisuals();
        end
    end

    function resetImage()
        if isempty(appData.imgHistory), return; end
        appData.imgHistory = {appData.imgHistory{1}}; 
        appData.maskHistory = {appData.maskHistory{1}};
        appData.histData = appData.histData(1, :);
        set([btnUndo, btnDownload], 'Enable', 'off');
        updateVisuals();
    end

    % PENGATURAN VISUALISASI
    function updateVisuals()
        if isempty(appData.imgHistory), return; end
        imgCurr = appData.imgHistory{end};
        maskCurr = appData.maskHistory{end};
        
        axis([axInImg axInSpec axMask axOutImg], 'on');
        
        % 1. Citra Masukan
        imshow(appData.imgHistory{1}, 'Parent', axInImg);
        title(axInImg, 'Citra Masukan');
        
        % 2. Citra Hasil
        imshow(imgCurr, 'Parent', axOutImg);
        title(axOutImg, 'Citra Hasil Penapisan / Restorasi');
        
        % 3. Spektrum Frekuensi Citra (Grayscale)
        grayCurr = imgCurr;
        if size(grayCurr, 3) == 3, grayCurr = rgb2gray(grayCurr); end
        F = fftshift(fft2(im2double(grayCurr)));
        S = log(1 + abs(F));
        S = S / max(S(:)); 
        imshow(S, 'Parent', axInSpec);
        title(axInSpec, 'Spektrum Frekuensi (Magnitude)');
        
        % 4. Mask Penapis H(u,v) atau PSF
        imshow(maskCurr, [], 'Parent', axMask);
        title(axMask, 'Visualisasi Mask H(u,v) / PSF');
        
        set(tblHistory, 'Data', appData.histData);
    end

    % GENERATOR MASK UNTUK VISUALISASI GUI
    function H = generate_lpf_mask(M, N, type, D0, n)
        u = -floor(M/2):ceil(M/2)-1; v = -floor(N/2):ceil(N/2)-1;
        [V, U] = meshgrid(v, u); D = sqrt(U.^2 + V.^2);
        if strcmpi(type, 'ideal'), H = double(D <= D0);
        elseif strcmpi(type, 'gaussian'), H = exp(-(D.^2)./(2*D0^2));
        else, H = 1 ./ (1 + (D./D0).^(2*n)); end
    end

    function H = generate_bandreject_mask(M, N, type, D0, W, n)
        u = -floor(M/2):ceil(M/2)-1; v = -floor(N/2):ceil(N/2)-1;
        [V, U] = meshgrid(v, u); D = sqrt(U.^2 + V.^2);
        if strcmpi(type, 'ideal'), H = double((D < (D0 - W/2)) | (D > (D0 + W/2)));
        elseif strcmpi(type, 'gaussian'), H = 1 - exp(-0.5 * ((D.^2 - D0^2) ./ (D.*W + eps)).^2);
        else, H = 1 ./ (1 + ((D.*W) ./ (D.^2 - D0^2 + eps)).^(2*n)); end
    end

    function psf_pad = generate_motion_blur_psf(M, N, len, theta)
        k = ceil(max(1, len)); psf = zeros(k, k); c = floor(k/2) + 1;
        tr = deg2rad(theta); xc = cos(tr); yc = -sin(tr);
        for i = 1:ceil(len)
            t = (i - 1) - (len - 1)/2; x = round(c + t * xc); y = round(c + t * yc);
            if x>=1 && x<=k && y>=1 && y<=k, psf(y, x) = psf(y, x) + 1; end
        end
        psf = psf / sum(psf(:));
        psf_pad = zeros(M, N);
        r1 = max(1, floor(M/2) - floor(k/2)); c1 = max(1, floor(N/2) - floor(k/2));
        psf_pad(r1:r1+k-1, c1:c1+k-1) = psf;
        psf_pad = psf_pad / max(psf_pad(:));
    end
end