import arcpy
arcpy.env.workspace = r'D:\NoahMp\FVC\S0_Origin'
output_path = r'D:\NoahMp\FVC\S1_resample\\'
rasterList = arcpy.ListRasters("*", "hdf")
for raster in rasterList:
    inRaster = raster
    out = output_path + inRaster[0:23] + '.tif'
    arcpy.Resample_management( inRaster , out , 0.1 , "BILINEAR")
