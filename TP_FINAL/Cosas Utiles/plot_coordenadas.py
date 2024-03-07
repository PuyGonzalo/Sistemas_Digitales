import numpy as np
import matplotlib.pyplot as plt

def plot_vector(x_end, y_end):
    # Create a 640x480 monochrome image (all ones for white background)
    width, height = 640, 480
    image = np.ones((height, width), dtype=np.uint8) * 255  # White background

    # Set black axes
    center_x, center_y = width // 2, height // 2
    image[center_y, :] = 0  # Horizontal axis (black)
    image[:, center_x] = 0  # Vertical axis (black)

    # Calculate vector from center to specified point
    dx, dy = x_end - center_x, y_end - center_y
    magnitude = np.sqrt(dx**2 + dy**2)
    normalized_dx, normalized_dy = dx / magnitude, dy / magnitude

    # Draw the vector
    for t in np.linspace(0, 1, int(magnitude)):
        x = int(center_x + t * dx)
        y = int(center_y + t * dy)
        image[y, x] = 0  # Black pixel along the vector

    # Display the image
    plt.imshow(image, cmap='gray', vmin=0, vmax=255)
    plt.axis('off')  # Hide axes
    plt.title(f"Vector from center to ({x_end}, {y_end})")
    plt.show()

# Example usage: Change these coordinates as needed
width, height = 640, 480
x = 2097
y = 2097
input_x = round((x/(2**4)))
input_y = round((y/(2**4)))

if x >= 0:
    target_x = input_x + (width/2)
    
if x < 0:
    target_x = abs( input_x + (width/2) )

if y >= 0:
    target_y = abs(input_y - (height/2))

if y < 0:
    target_y = abs(input_y - (height/2))


plot_vector(target_x, target_y)

