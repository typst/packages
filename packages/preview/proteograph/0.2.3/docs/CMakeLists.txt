

#include(${CMAKE_SOURCE_DIR}/UseTYPST.cmake)


add_typst_document_root(proteograph-docs proteograph-docs.typ)

add_custom_target(docs ALL DEPENDS proteograph-docs)

add_custom_command(TARGET proteograph-docs POST_BUILD
	COMMAND ${CMAKE_COMMAND} -E copy
        "${CMAKE_CURRENT_BINARY_DIR}/proteograph-docs.pdf"
        "${CMAKE_SOURCE_DIR}/docs")


