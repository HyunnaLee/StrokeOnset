function [segment_mask] = JMRI_remove_small_cluster(adc_mask,segment_mask,pixdim,ccthr)
sz = size(adc_mask);
lgc_mask    = adc_mask>0;
segment_mask(~lgc_mask) = 0;
segment_mask = logical(segment_mask);
cc = bwconncomp(double(segment_mask),6);
ccpervoxel = pixdim(1)*pixdim(2)*pixdim(3)/1000;
voxelthr = round(ccthr/ccpervoxel);
for n=1:numel(cc.PixelIdxList)
    if numel(cc.PixelIdxList{n})<voxelthr
        for nn=1:numel(cc.PixelIdxList{n})
            [x,y,z] = ind2sub(sz,cc.PixelIdxList{n}(nn));
            segment_mask(x,y,z) = false;
        end
    end
end
segment_mask = double(segment_mask);
return;