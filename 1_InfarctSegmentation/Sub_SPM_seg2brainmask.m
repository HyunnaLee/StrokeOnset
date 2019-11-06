function Sub_SPM_seg2brainmask(sourcepath, filename)
spm('defaults','PET');
matlabbatch{1}.spm.util.imcalc.input = {
                                        [sourcepath filesep 'c1' filename]
                                        [sourcepath filesep 'c2' filename]
                                        [sourcepath filesep 'c3' filename]
                                        };
matlabbatch{1}.spm.util.imcalc.output = ['brain_' filename];
matlabbatch{1}.spm.util.imcalc.outdir = {sourcepath};
matlabbatch{1}.spm.util.imcalc.expression = '(i1+i2+i3)>0.5';
matlabbatch{1}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{1}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);
end