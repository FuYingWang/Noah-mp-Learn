import arcpy
arcpy.env.workspace = r'D:\NoahMp\LAI\S1_Resample'
output_file = r'D:\NoahMp\LAI\S2_Reproject\\'
Rasters = arcpy.ListRasters( "*" , "tif")
print(Rasters)

proj = arcpy.Describe('D:\NoahMp\CMFD_Mask.tif').spatialReference
for raster in Rasters :
    out = output_file + raster
    arcpy.ProjectRaster_management(raster, out, proj, "NEAREST", "", "", "", "", "")
