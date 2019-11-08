function Sub_SPM_ratio2img(img, path, file)

spm('defaults','PET');
matlabbatch{1}.spm.util.imcalc.input = {
                                        [path filesep file]
                                        };
matlabbatch{1}.spm.util.imcalc.output = ['ratio_' file];
matlabbatch{1}.spm.util.imcalc.outdir = {path};
matlabbatch{1}.spm.util.imcalc.expression = 'i1';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 16;
spm_jobman('run', matlabbatch);

nii = load_untouch_nii([path filesep 'ratio_' file]);
nii.img = img;
save_untouch_nii(nii, [path filesep 'ratio_' file]);

end