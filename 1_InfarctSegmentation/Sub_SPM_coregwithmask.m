function Sub_SPM_coregwithmask(ref_file, source_file, mask_file)
spm('defaults','PET');
matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {ref_file};
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {source_file};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {mask_file};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'mid_';
spm_jobman('run',matlabbatch);
end