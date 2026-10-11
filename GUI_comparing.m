function GUI_comparing()
    % PATH DAN INISIALISASI VARIABEL UTAMA
    addpath(genpath('src'));
    addpath(genpath('02_citra_test_images'));

    appData = struct();
    appData.originalImg = [];
    appData.refImg      = []; % Variabel penyimpan citra referensi
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
                  'Peningkatan Kecerahan (Brightness Adjustment)', ...
                  'Restorasi Derau Periodik (Bandreject Filter)', ...
                  'Restorasi Derau Periodik (Notch Reject Filter)', ...
                  'Restorasi Motion Blur'};
              
    popMethod = uicontrol('Parent', pnlMeth, 'Style', 'popupmenu', ...
                          'String', metodeList, 'Value', 1, 'Position', [65, 258, 325, 25], 'Callback', @methodChanged);
                      
    % KOLOM INPUT PARAMETER DINAMIS
    % 1. LPF / HPF / Bandreject / Notch Filters (Group 1)
    txtType1 = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Tipe Filter:', 'HorizontalAlignment', 'left', 'Position', [10, 210, 100, 20], 'Visible', 'off');
    popType1 = uicontrol('Parent', pnlMeth, 'Style', 'popupmenu', 'String', {'Ideal', 'Gaussian', 'Butterworth'}, 'Position', [115, 208, 275, 25], 'Visible', 'off');
    set(popType1, 'Callback', @filterTypeChanged); % Callback untuk memunculkan/menyembunyikan Orde
    
    txtD0 = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Cut-off (D0):', 'HorizontalAlignment', 'left', 'Position', [10, 178, 100, 20], 'Visible', 'off');
    editD0 = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '50', 'Position', [115, 178, 275, 22], 'Visible', 'off');
    
    txtW = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Lebar Pita (W):', 'HorizontalAlignment', 'left', 'Position', [10, 146, 100, 20], 'Visible', 'off');
    editW = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '10', 'Position', [115, 146, 275, 22], 'Visible', 'off');
    
    % Input Khusus Notch Filter
    txtUk = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Pusat U (uk):', 'HorizontalAlignment', 'left', 'Position', [10, 146, 70, 20], 'Visible', 'off');
    editUk = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '60', 'Position', [85, 146, 80, 22], 'Visible', 'off');
    txtVk = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Pusat V (vk):', 'HorizontalAlignment', 'left', 'Position', [180, 146, 70, 20], 'Visible', 'off');
    editVk = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '60', 'Position', [255, 146, 80, 22], 'Visible', 'off');

    txtOrde = uicontrol('Parent', pnlMeth, 'Style', 'text', 'String', 'Orde:', 'HorizontalAlignment', 'left', 'Position', [10, 114, 100, 20], 'Visible', 'off');
    editOrde = uicontrol('Parent', pnlMeth, 'Style', 'edit', 'String', '2', 'Position', [115, 114, 275, 22], 'Visible', 'off');
    
    groupFiltersBase = [txtType1, popType1, txtD0, editD0];
    groupOrde        = [txtOrde, editOrde];
    groupBandreject  = [txtW, editW]; 
    groupNotch       = [txtUk, editUk, txtVk, editVk];

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

    % VISUALISASI KANAN DENGAN RADIO BUTTON MODE TAMPILAN
    pnlRight = uipanel('Parent', fig, 'Title', 'Visualisasi Frekuensi, Spasial, dan Komparasi', 'FontWeight', 'bold', 'Units', 'pixels', 'Position', [440, 10, 870, 660]);
    
    % Toggle Mode Tampilan
    bgView = uibuttongroup('Parent', pnlRight, 'Units', 'normalized', 'Position', [0.25, 0.92, 0.45, 0.07], 'BorderType', 'none', 'SelectionChangedFcn', @(~,~) updateVisuals());
    rbFreq = uicontrol(bgView, 'Style', 'radiobutton', 'String', 'Mode Analisis Frekuensi (4 Kuadran)', 'Units', 'normalized', 'Position', [0.05, 0.2, 0.45, 0.6], 'FontWeight', 'bold');
    rbComp = uicontrol(bgView, 'Style', 'radiobutton', 'String', 'Mode Komparasi Lengkap (6 Kolom)', 'Units', 'normalized', 'Position', [0.55, 0.2, 0.45, 0.6], 'FontWeight', 'bold');

    % Text label untuk metrik evaluasi objektif (MSE & PSNR)
    lblMetrics = uicontrol('Parent', pnlRight, 'Style', 'text', 'String', '', 'FontSize', 10, 'FontWeight', 'bold', ...
                           'ForegroundColor', [0 0.4 0.7], 'Units', 'normalized', 'Position', [0.72, 0.92, 0.25, 0.05], ...
                           'HorizontalAlignment', 'right', 'Visible', 'off');

    % Inisialisasi 7 Axes (Disesuaikan untuk Mode 1 dan Mode 2)
    axInImg     = axes('Parent', pnlRight, 'Position', [0.05, 0.48, 0.40, 0.40]); 
    axOutImg    = axes('Parent', pnlRight, 'Position', [0.55, 0.03, 0.40, 0.40]); 
    axInSpec    = axes('Parent', pnlRight, 'Position', [0.55, 0.48, 0.40, 0.40]); 
    axMask      = axes('Parent', pnlRight, 'Position', [0.05, 0.03, 0.40, 0.40]); 
    axRefImg    = axes('Parent', pnlRight, 'Position', [0.68, 0.25, 0.30, 0.50]); 
    axOutSpec   = axes('Parent', pnlRight, 'Position', [0.35, 0.05, 0.30, 0.38]); % Khusus Mode 2
    axRefSpec   = axes('Parent', pnlRight, 'Position', [0.68, 0.05, 0.30, 0.38]); % Khusus Mode 2
    
    axis([axInImg axInSpec axMask axOutImg axRefImg axOutSpec axRefSpec], 'off');

    % =========================================================================
    % TOMBOL SIMPAN INDIVIDUAL (OPSI TITIK) UNTUK SETIAP PANEL GAMBAR
    % =========================================================================
    btnProps = {'Style', 'pushbutton', 'String', '💾', 'Units', 'normalized', 'FontSize', 10, 'TooltipString', 'Simpan Tampilan Ini', 'Visible', 'off'};
    btnSaveInImg   = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axInImg, 'citra_masukan.png'));
    btnSaveOutImg  = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axOutImg, 'citra_hasil.png'));
    btnSaveRefImg  = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axRefImg, 'citra_referensi.png'));
    btnSaveInSpec  = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axInSpec, 'spektrum_masukan.png'));
    btnSaveOutSpec = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axOutSpec, 'spektrum_hasil.png'));
    btnSaveRefSpec = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axRefSpec, 'spektrum_referensi.png'));
    btnSaveMask    = uicontrol('Parent', pnlRight, btnProps{:}, 'Callback', @(~,~) saveSinglePlot(axMask, 'mask_psf.png'));
    
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
        
        targetDir = fullfile(appData.baseDir, selFld, 'input');
        if ~exist(targetDir, 'dir'), targetDir = fullfile(appData.baseDir, selFld); end
        
        f = dir(fullfile(targetDir, '*.*'));
        fNames = {f(~[f.isdir]).name}'; fNames = fNames(~startsWith(fNames, '.'));
        if isempty(fNames), fNames = {'(Kosong)'}; end
        set(popFil, 'String', fNames, 'Value', 1);
    end
    
    function filterTypeChanged(~, ~)
        valMeth = get(popMethod, 'Value');
        if ismember(valMeth, [1, 2, 4, 5]) % LPF, HPF, Bandreject, Notch
            opts = get(popType1, 'String');
            selType = lower(opts{get(popType1, 'Value')});
            if strcmp(selType, 'butterworth')
                set(groupOrde, 'Visible', 'on');
            else
                set(groupOrde, 'Visible', 'off');
            end
        else
            set(groupOrde, 'Visible', 'off');
        end
    end

    function methodChanged(~, ~)
        val = get(popMethod, 'Value');
        set(groupFiltersBase, 'Visible', 'off');
        set(groupOrde, 'Visible', 'off');
        set(groupBandreject, 'Visible', 'off');
        set(groupNotch, 'Visible', 'off');
        set(groupBrightness, 'Visible', 'off');
        set(groupMB, 'Visible', 'off');
        
        if val == 1 || val == 2 % LPF / HPF
            set(groupFiltersBase, 'Visible', 'on');
            filterTypeChanged();
        elseif val == 3 % Brightness
            set(groupBrightness, 'Visible', 'on');
        elseif val == 4 % Periodic Noise (Bandreject)
            set(groupFiltersBase, 'Visible', 'on');
            set(groupBandreject, 'Visible', 'on');
            filterTypeChanged(); 
        elseif val == 5 % Periodic Noise (Notch Reject)
            set(groupFiltersBase, 'Visible', 'on');
            set(groupNotch, 'Visible', 'on');
            filterTypeChanged(); 
        elseif val == 6 % Motion Blur
            set(groupMB, 'Visible', 'on');
        end
    end

    function loadImage()
        folders = get(popFolder, 'String'); folderSelected = folders{get(popFolder, 'Value')};
        files = get(popFile, 'String'); fileSelected = files{get(popFile, 'Value')};
        if strcmp(folderSelected, '(Kosong)') || strcmp(fileSelected, '(Kosong)'), return; end
        
        % Cari Input
        targetDir = fullfile(appData.baseDir, folderSelected, 'input');
        if ~exist(targetDir, 'dir'), targetDir = fullfile(appData.baseDir, folderSelected); end
        imgPath = fullfile(targetDir, fileSelected);
        if ~exist(imgPath, 'file'), errordlg('File tidak ditemukan!'); return; end

        % Cari Referensi (Pencocokan Nama Pintar)
        refDir = fullfile(appData.baseDir, folderSelected, 'reference');
        appData.refImg = []; % Kosongkan default
        
        if exist(refDir, 'dir')
            refFiles = dir(fullfile(refDir, '*.*'));
            refNames = {refFiles(~[refFiles.isdir]).name};
            [~, nameIn, ~] = fileparts(fileSelected);
            
            for i = 1:length(refNames)
                if ~startsWith(refNames{i}, '.')
                    [~, nameRef, ~] = fileparts(refNames{i});
                    if startsWith(nameIn, nameRef)
                        appData.refImg = imread(fullfile(refDir, refNames{i}));
                        break;
                    end
                end
            end
        end

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
            if metodeVal == 1 
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); 
                orde = str2double(get(editOrde, 'String'));
                
                imgOut = lowpass_filter(imgIn, fType, D0, orde);
                
                if strcmpi(fType, 'butterworth')
                    paramStr = sprintf('LPF %s, D0=%g, orde=%g', fType, D0, orde);
                else
                    paramStr = sprintf('LPF %s, D0=%g', fType, D0);
                end
                H_disp = generate_lpf_mask(M, N, fType, D0, orde);
                
            elseif metodeVal == 2
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); 
                orde = str2double(get(editOrde, 'String'));
                
                imgOut = highpass_filter(imgIn, fType, D0, orde);
                
                if strcmpi(fType, 'butterworth')
                    paramStr = sprintf('HPF %s, D0=%g, orde=%g', fType, D0, orde);
                else
                    paramStr = sprintf('HPF %s, D0=%g', fType, D0);
                end
                H_disp = 1 - generate_lpf_mask(M, N, fType, D0, orde); 
                
            elseif metodeVal == 3
                scaleF = str2double(get(editScale, 'String'));
                imgOut = brightness_adjustment(imgIn, scaleF);
                paramStr = sprintf('Scale DC = %g', scaleF);
                H_disp = zeros(M, N); H_disp(floor(M/2)+1, floor(N/2)+1) = 1; 
                
            elseif metodeVal == 4
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); W = str2double(get(editW, 'String'));
                orde = str2double(get(editOrde, 'String'));
                
                imgOut = bandreject_filter(imgIn, fType, D0, W, orde);
                
                if strcmpi(fType, 'butterworth')
                    paramStr = sprintf('BRF %s, D0=%g, W=%g, orde=%g', fType, D0, W, orde);
                else
                    paramStr = sprintf('BRF %s, D0=%g, W=%g', fType, D0, W);
                end
                H_disp = generate_bandreject_mask(M, N, fType, D0, W, orde);
                
            elseif metodeVal == 5
                opts = get(popType1, 'String'); fType = lower(opts{get(popType1, 'Value')});
                D0 = str2double(get(editD0, 'String')); 
                uk = str2double(get(editUk, 'String'));
                vk = str2double(get(editVk, 'String'));
                orde = str2double(get(editOrde, 'String'));
                
                imgOut = notch_reject_filter(imgIn, fType, uk, vk, D0, orde);
                
                if strcmpi(fType, 'butterworth')
                    paramStr = sprintf('Notch %s, D0=%g, uk=%g, vk=%g, orde=%g', fType, D0, uk, vk, orde);
                else
                    paramStr = sprintf('Notch %s, D0=%g, uk=%g, vk=%g', fType, D0, uk, vk);
                end
                H_disp = generate_notch_mask(M, N, fType, uk, vk, D0, orde);

            elseif metodeVal == 6
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

    function downloadImage()
        if length(appData.imgHistory) < 2, return; end
        prompt = {'Masukkan nama file (tanpa ekstensi .png):'};
        answer = inputdlg(prompt, 'Simpan Citra Restorasi', [1 50], {'hasil_restorasi'});
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

    % --- FUNGSI PEMBANTU UNTUK MENGHITUNG & PLOT SPEKTRUM ---
    function plotSpectrum(targetAx, img, titleStr)
        if isempty(img)
            cla(targetAx); axis(targetAx, 'off');
            text(0.5, 0.5, 'Tidak Tersedia', 'Parent', targetAx, ...
                 'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
            return;
        end
        if size(img, 3) == 3, img = rgb2gray(img); end
        F = fftshift(fft2(im2double(img)));
        S = log(1 + abs(F)); 
        S = S / max(S(:)); 
        imshow(S, 'Parent', targetAx);
        title(targetAx, titleStr);
    end

    % --- FUNGSI ALIGNMENT TOMBOL SIMPAN ---
    function alignSaveButton(btn, axPos)
        % Menempatkan tombol "Disket" persis di pojok kanan atas koordinat axes
        btnW = 0.035; btnH = 0.045;
        set(btn, 'Position', [axPos(1) + axPos(3) - btnW, axPos(2) + axPos(4) - btnH, btnW, btnH], 'Visible', 'on');
    end

    % --- PENGATURAN VISUALISASI DINAMIS (FREKUENSI vs KOMPARASI) ---
    function updateVisuals()
        if isempty(appData.imgHistory), return; end
        imgOrig = appData.imgHistory{1};
        imgCurr = appData.imgHistory{end};
        maskCurr = appData.maskHistory{end};
        
        viewMode = get(bgView, 'SelectedObject');
        
        % Sembunyikan semua tombol simpan (reset state)
        set([btnSaveInImg, btnSaveOutImg, btnSaveRefImg, btnSaveInSpec, btnSaveOutSpec, btnSaveRefSpec, btnSaveMask], 'Visible', 'off');
        
        if viewMode == rbFreq
            % --- MODE 1: ANALISIS FREKUENSI (4 Kuadran) ---
            set([axRefImg, axOutSpec, axRefSpec], 'Visible', 'off'); 
            set(lblMetrics, 'Visible', 'off'); % Sembunyikan metrik di mode ini
            cla(axRefImg); cla(axOutSpec); cla(axRefSpec);
            title(axRefImg, ''); title(axOutSpec, ''); title(axRefSpec, '');
            
            pInImg = [0.05, 0.48, 0.40, 0.40];
            pOutImg = [0.55, 0.03, 0.40, 0.40];
            pInSpec = [0.55, 0.48, 0.40, 0.40];
            pMask = [0.05, 0.03, 0.40, 0.40];

            set(axInImg, 'Position', pInImg);
            set(axOutImg, 'Position', pOutImg);
            set(axInSpec, 'Position', pInSpec, 'Visible', 'on');
            set(axMask, 'Position', pMask, 'Visible', 'on');
            
            % Plot Masukan dan Hasil
            imshow(imgOrig, 'Parent', axInImg); title(axInImg, 'Citra Masukan / Terdegradasi');
            imshow(imgCurr, 'Parent', axOutImg); title(axOutImg, 'Citra Hasil Penapisan / Restorasi');
            
            % Plot Spektrum dan Mask
            plotSpectrum(axInSpec, imgCurr, 'Spektrum Frekuensi');
            imshow(maskCurr, [], 'Parent', axMask); title(axMask, 'Mask H(u,v) / PSF');

            % Atur tombol simpan
            alignSaveButton(btnSaveInImg, pInImg);
            alignSaveButton(btnSaveOutImg, pOutImg);
            alignSaveButton(btnSaveInSpec, pInSpec);
            alignSaveButton(btnSaveMask, pMask);
            
        else
            % --- MODE 2: KOMPARASI REFERENSI (6 Panel: 3 Atas, 3 Bawah) ---
            set(axMask, 'Visible', 'off'); cla(axMask); title(axMask, '');
            
            % Konfigurasi ukuran matriks 3 kolom x 2 baris
            w = 0.30; h = 0.38;
            yTop = 0.52; yBot = 0.05;
            x1 = 0.02; x2 = 0.35; x3 = 0.68;
            
            pInImg = [x1, yTop, w, h]; pOutImg = [x2, yTop, w, h]; pRefImg = [x3, yTop, w, h];
            pInSpec = [x1, yBot, w, h]; pOutSpec = [x2, yBot, w, h]; pRefSpec = [x3, yBot, w, h];

            set(axInImg, 'Position', pInImg);
            set(axOutImg, 'Position', pOutImg);
            set(axRefImg, 'Position', pRefImg, 'Visible', 'on');
            
            set(axInSpec, 'Position', pInSpec, 'Visible', 'on');
            set(axOutSpec, 'Position', pOutSpec, 'Visible', 'on');
            set(axRefSpec, 'Position', pRefSpec, 'Visible', 'on');
            
            % Plot Gambar Spasial (Baris Atas)
            imshow(imgOrig, 'Parent', axInImg); title(axInImg, 'Citra Masukan');
            imshow(imgCurr, 'Parent', axOutImg); title(axOutImg, 'Hasil Restorasi Manual');
            
            % Atur tombol simpan standar
            alignSaveButton(btnSaveInImg, pInImg);
            alignSaveButton(btnSaveOutImg, pOutImg);
            alignSaveButton(btnSaveInSpec, pInSpec);
            alignSaveButton(btnSaveOutSpec, pOutSpec);

            % Hitung dan tampilkan MSE & PSNR jika referensi ada
            if ~isempty(appData.refImg)
                imshow(appData.refImg, 'Parent', axRefImg); title(axRefImg, 'Citra Referensi (Kunci Jawaban)');
                
                % Tampilkan tombol simpan referensi
                alignSaveButton(btnSaveRefImg, pRefImg);
                alignSaveButton(btnSaveRefSpec, pRefSpec);

                % Perhitungan MSE dan PSNR secara manual
                if isequal(size(imgCurr), size(appData.refImg))
                    diffImg = double(imgCurr) - double(appData.refImg);
                    mseVal = mean(diffImg(:).^2);
                    if mseVal == 0
                        psnrVal = Inf;
                    else
                        psnrVal = 10 * log10((255^2) / mseVal);
                    end
                    metricText = sprintf('MSE: %.2f  |  PSNR: %.2f dB', mseVal, psnrVal);
                else
                    metricText = 'Dimensi matriks citra tidak cocok untuk metrik';
                end
                
                % Tampilkan teks metrik di pojok kanan atas
                set(lblMetrics, 'String', metricText, 'Visible', 'on');
            else
                cla(axRefImg); axis(axRefImg, 'off');
                text(0.5, 0.5, 'Referensi Tidak Tersedia', 'Parent', axRefImg, ...
                     'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
                set(lblMetrics, 'Visible', 'off');
            end
            
            % Plot Spektrum Frekuensi (Baris Bawah)
            plotSpectrum(axInSpec, imgOrig, 'Spektrum Masukan');
            plotSpectrum(axOutSpec, imgCurr, 'Spektrum Hasil Manual');
            plotSpectrum(axRefSpec, appData.refImg, 'Spektrum Referensi');
        end
        
        set(tblHistory, 'Data', appData.histData);
    end

    % GENERATOR MASK UNTUK VISUALISASI GUI
    function H = generate_lpf_mask(M, N, type, D0, orde)
        u = -floor(M/2):ceil(M/2)-1; v = -floor(N/2):ceil(N/2)-1;
        [V, U] = meshgrid(v, u); D = sqrt(U.^2 + V.^2);
        if strcmpi(type, 'ideal'), H = double(D <= D0);
        elseif strcmpi(type, 'gaussian'), H = exp(-(D.^2)./(2*D0^2));
        else, H = 1 ./ (1 + (D./D0).^(2*orde)); end
    end

    function H = generate_bandreject_mask(M, N, type, D0, W, orde)
        u = -floor(M/2):ceil(M/2)-1; v = -floor(N/2):ceil(N/2)-1;
        [V, U] = meshgrid(v, u); D = sqrt(U.^2 + V.^2);
        if strcmpi(type, 'ideal'), H = double((D < (D0 - W/2)) | (D > (D0 + W/2)));
        elseif strcmpi(type, 'gaussian'), H = 1 - exp(-0.5 * ((D.^2 - D0^2) ./ (D.*W + eps)).^2);
        else, H = 1 ./ (1 + ((D.*W) ./ (D.^2 - D0^2 + eps)).^(2*orde)); end
    end

    function H = generate_notch_mask(M, N, type, uk, vk, D0, orde)
        u = -floor(M/2):ceil(M/2)-1; v = -floor(N/2):ceil(N/2)-1;
        [V, U] = meshgrid(v, u);
        D1 = sqrt((U - uk).^2 + (V - vk).^2);
        D2 = sqrt((U + uk).^2 + (V + vk).^2);
        if strcmpi(type, 'ideal')
            H1 = double(D1 > D0); H2 = double(D2 > D0); H = H1 .* H2;
        elseif strcmpi(type, 'gaussian')
            H1 = 1 - exp(-(D1.^2)./(2*D0^2)); H2 = 1 - exp(-(D2.^2)./(2*D0^2)); H = H1 .* H2;
        else
            H1 = 1 ./ (1 + (D0 ./ (D1 + eps)).^(2*orde));
            H2 = 1 ./ (1 + (D0 ./ (D2 + eps)).^(2*orde));
            H = H1 .* H2;
        end
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

    % =========================================================================
    % FUNGSI UNTUK MENYIMPAN GAMBAR DARI AXES TERPILIH
    % =========================================================================
    function saveSinglePlot(ax, defaultName)
        % Cari objek gambar ('Image') di dalam axes yang diklik
        imgObj = findobj(ax, 'Type', 'image');
        if isempty(imgObj)
            msgbox('Tidak ada gambar yang dimuat pada panel ini.', 'Info', 'warn');
            return;
        end
        
        % Ambil data matriks gambar
        imgData = imgObj.CData;

        % Buka dialog simpan file
        [file, path] = uiputfile({'*.png', 'PNG Image (*.png)'; '*.jpg', 'JPEG Image (*.jpg)'}, ...
                                 'Simpan Gambar Panel', defaultName);
                             
        % Jika user menekan Cancel
        if isequal(file, 0) || isequal(path, 0)
            return; 
        end

        try
            % Jika data bertipe desimal (misal visualisasi mask atau spektrum logaritmik)
            if isfloat(imgData)
                % Normalisasi manual (tanpa Image Processing Toolbox) ke rentang 0-1
                min_val = min(imgData(:));
                max_val = max(imgData(:));
                if max_val > min_val
                    imgData = (imgData - min_val) ./ (max_val - min_val);
                else
                    imgData = zeros(size(imgData));
                end
                
                % Konversi ke format 8-bit (0-255)
                imgData = uint8(imgData * 255);
            end
            
            % Tulis (simpan) matriks menjadi file citra
            imwrite(imgData, fullfile(path, file));
            msgbox(['Gambar berhasil disimpan di:', newline, fullfile(path, file)], 'Sukses');
        catch ME
            errordlg(['Terjadi kesalahan saat menyimpan gambar:', newline, ME.message], 'Error Simpan');
        end
    end
end