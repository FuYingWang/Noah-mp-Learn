import arcpy

inMaskData = r'D:\NoahMp\CMFD_Mask.tif'

arcpy.env.workspace = r'D:\NoahMp\LAI\S2_Reproject'
arcpy.env.snapRaster = 'inMaskData'

out_path = r'D:\NoahMp\LAI\S3_Tailor\\'

rasterList = arcpy.ListRasters("*", "tif")

for filen in rasterList :
        outname = out_path + filen
        print(outname)
        arcpy.Clip_management(filen, "", outname, inMaskData, "#", "#", "MAINTAIN_EXTENT")

