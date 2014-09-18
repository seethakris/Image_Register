Image_Register
==============

Register a data with a representative fish. 

image_register_main - Main script that runs all the following subscripts. All important variables are defined here. 

1. get_image_correlation - Run cross correlation between data stacks and representative stacks.
                           Find and save the x and y offsets. 
                           
2. image_correlation_registration - Check for the best correlated Z-plane for each data stack and the rep stack. 
                                    Register the data image to the Z-plane using the x and y offsets
                                    If flag = 1, use only top and bottom Z and calculate the rest using z-plane distance
                                    during data collection
                                    Save the registered images as a tif
                                    
3. get_kiss_overlap - Looks for Kiss neurons in the registered image and plots intensity profile of ROIs that                            are Kiss+ and Kiss- cells 

                                
      
