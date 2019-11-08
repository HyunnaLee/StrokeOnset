function Sub_SPM_seg2brainmask(path, file)
spm('defaults','PET');
matlabbatch{1}.spm.spatial.normalise.write.subj.def = {[path filesep 'iy_' file]};
matlabbatch{1}.spm.spatial.normalise.write.subj.resample = {'mask_midplane.nii'};
matlabbatch{1}.spm.spatial.normalise.write.woptions.bb = [-120 -120 -120
                                                          120 120 120];
matlabbatch{1}.spm.spatial.normalise.write.woptions.vox = [1 1 1];
matlabbatch{1}.spm.spatial.normalise.write.woptions.interp = 0;

matlabbatch{2}.spm.util.imcalc.input = {
                                        [path filesep file]
                                        'wmask_midplane.nii'
                                        };
matlabbatch{2}.spm.util.imcalc.output = ['mid_' file];
matlabbatch{2}.spm.util.imcalc.outdir = {path};
matlabbatch{2}.spm.util.imcalc.expression = 'i2>0.5';
matlabbatch{2}.spm.util.imcalc.var = struct('name', {}, 'value', {});
matlabbatch{2}.spm.util.imcalc.options.dmtx = 0;
matlabbatch{2}.spm.util.imcalc.options.mask = 0;
matlabbatch{2}.spm.util.imcalc.options.interp = 1;
matlabbatch{2}.spm.util.imcalc.options.dtype = 4;
spm_jobman('run', matlabbatch);

delete('wmask_midplane.nii');
end