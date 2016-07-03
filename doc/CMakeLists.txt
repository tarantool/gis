find_program(SPHINXBUILD sphinx-build)
if (NOT SPHINXBUILD)
    return()
endif()

add_custom_target(doc-html
    COMMAND sphinx-build -b html -d "${CMAKE_CURRENT_BINARY_DIR}/_build"
        "${CMAKE_CURRENT_SOURCE_DIR}"
        "${CMAKE_CURRENT_BINARY_DIR}/html"
)
