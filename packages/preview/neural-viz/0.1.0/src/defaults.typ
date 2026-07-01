#import "draw/arrows.typ": make-arrow
#import "nodes/dataset.typ": make-dataset
#import "nodes/image.typ": make-image-node, make-image-dataset
#import "nodes/latent.typ": make-latent-space
#import "nodes/trapezoid.typ": make-trapezoid
#import "nodes/box.typ": make-box

#let set-arrow-defaults(options: ()) = make-arrow.with(..options)
#let set-dataset-defaults(options: ()) = make-dataset.with(..options)
#let set-image-node-defaults(options: ()) = make-image-node.with(..options)
#let set-image-dataset-defaults(options: ()) = make-image-dataset.with(..options)
#let set-latent-space-defaults(options: ()) = make-latent-space.with(..options)
#let set-trapezoid-defaults(options: ()) = make-trapezoid.with(..options)
#let set-box-defaults(options: ()) = make-box.with(..options)
