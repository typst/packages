= 0218. The Skyline Problem

A city's *skyline* is the outer contour of the silhouette formed by all the buildings in that city when viewed from a distance.

Given the locations and heights of all the buildings, return the *skyline* formed by these buildings collectively.

The geometric information of each building is given in the array `buildings` where `buildings[i] = [left_i, right_i, height_i]`:
- `left_i` is the x coordinate of the left edge of the $i^"th"$ building.
- `right_i` is the x coordinate of the right edge of the $i^"th"$ building.
- `height_i` is the height of the $i^"th"$ building.

You may assume all buildings are perfect rectangles grounded on an absolutely flat surface at height 0.

The *skyline* should be represented as a list of "key points" sorted by their x-coordinate in the form `[[x_1, y_1], [x_2, y_2], ...]`. Each key point is the left endpoint of some horizontal segment in the skyline except the last point, which always has a y-coordinate 0 and is used to mark the skyline's termination.

*Note:* There must be no consecutive horizontal lines of equal height in the output skyline.

*Constraints:*
- $1 <=$ `buildings.length` $<= 10^4$
- $0 <= "left"_i < "right"_i <= 2^31 - 1$
- $1 <= "height"_i <= 2^31 - 1$
- `buildings` is sorted by `left_i` in non-decreasing order.
