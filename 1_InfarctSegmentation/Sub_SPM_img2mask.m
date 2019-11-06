function Sub_SPM_img2mask(path, file, prefix)
spm('defaults','PET');
matlabbatch{1}.spm.util.imcalc.input = {
                                        [path filesep file]
                                        };
matlabbatch{1}.spm.util.imcalc.output = [prefix file];
matlabbatch{1}.spm.util.imcalc.outdir = {path};
matlabbatch{1}.spm.util.imcalc.expression = 'i1>0';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
end