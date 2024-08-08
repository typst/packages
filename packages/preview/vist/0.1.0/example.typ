#import "src/lib.typ": *
// 假定的初始图像数据，实际使用时需替换为真实图像字节流
#let image_data = read("image.png",encoding: none)
this file is #type.img_type(image_data)

the metadata of this file is #get_image_metadata(image_data)

// 测试亮度调整函数
#let brightened_image = brighten(image_data, value: 20)
#image.decode(brightened_image)

// 测试色相旋转函数
#let hue_rotated_image = huerotate(image_data, value: 90)
#image.decode(hue_rotated_image)

// 测试颜色反转函数
#let inverted_image = invert(image_data)
#image.decode(inverted_image)

// 测试模糊函数
#let blurred_image = blur(image_data, sigma: 2.5)
#image.decode(blurred_image)

// 测试锐化掩膜函数
#let unsharpened_image = unsharpen(image_data, sigma: 1.0, threshold: 10)
#image.decode(unsharpened_image)

// 测试对比度调整函数
#let contrast_adjusted_image = adjust_contrast(image_data, value: 50)
#image.decode(contrast_adjusted_image)

// 测试旋转180度函数
#let rotated180_image = rotate180(image_data)
#image.decode(rotated180_image)

// 测试旋转270度函数
#let rotated270_image = rotate270(image_data)
#image.decode(rotated270_image)

// 测试灰度转换函数
#let grayscale_image = grayscale(image_data)
#image.decode(grayscale_image)

// 测试裁剪函数
#let cropped_image = crop(image_data, x: 10, y: 10, width: 100, height: 100)
#image.decode(cropped_image)

// 测试缩略图创建函数
#let thumbnail_image = thumbnail(image_data, width: 100, height: 100)
#image.decode(thumbnail_image)

// 测试图像缩放函数
#let resized_image = resize(image_data, width: 200, height: 200, filter_type: 3)
#image.decode(resized_image)

// 测试填充缩放函数
#let resized_to_fill_image = resize_to_fill(image_data, width: 200, height: 200, filter_type: 0)
#image.decode(resized_to_fill_image)

// 测试3x3卷积滤波函数
#let kernel = (1, 0, -1, 0, 0, 0, -1, 0, 1)
#let filtered_image = filter3x3(image_data, kernel: kernel)
#image.decode(filtered_image)

// 测试创建水平渐变函数
#let horizontal_gradient_image = horizontal_gradient( width: 200, height: 200, start_color: (255, 0, 0, 255), end_color: (0, 0, 255, 255))
#image.decode(horizontal_gradient_image)

// 测试创建垂直渐变函数
#let vertical_gradient_image = vertical_gradient( width: 200, height: 200, start_color: (255, 255, 0, 255), end_color: (0, 255, 0, 255))
#image.decode(vertical_gradient_image)

// 测试图像覆盖函数
#let base_image_data = read("image.png",encoding: none) // 基础图像数据
#let overlay_image_data = read("png-0.webp",encoding: none) // 要覆盖的图像数据
#let overlay_image = overlay(base_image_data, overlay_image_data, x: 50, y: 50)
#image.decode(overlay_image)

// 测试图像平铺函数
#let tile_image_data = read("png-0.webp",encoding: none) // 平铺图像数据
"png-0.webp" is #type.img_type(tile_image_data)
#let tiled_image = tile(base_image_data, tile_image_data)
#image.decode(tiled_image)

// 测试双线性插值函数
#let bilinear_image = interpolate_bilinear(image_data, x: 25.5, y: 25.5)


// 测试最近邻插值函数
#let nearest_neighbor_image = interpolate_nearest(image_data, x: 25.5, y: 25.5)


// 测试垂直翻转函数
#let vertical_flipped_image = flip_vertical(image_data)
#image.decode(vertical_flipped_image)

// 测试水平翻转函数
#let horizontal_flipped_image = flip_horizontal(image_data)
#image.decode(horizontal_flipped_image)

// 测试90度顺时针旋转函数
#let rotated90_image = rotate90(image_data)
#image.decode(rotated90_image)

// 测试图像格式转换函数
#let converted_format_image = convert_format(image_data, format: "jpeg", quality: 80)
#image.decode(converted_format_image)
