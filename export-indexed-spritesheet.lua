local TMP_FILE_PATH <const> = app.fs.joinPath(app.fs.tempPath, "indexed_sprite_sheet.png")

function main()
    if app.isUIAvailable == false then
        print("Headless mode not supported.")
        return
    end

    if app.sprite == nil then
        app.alert("Please open a sprite you want to export.")
        return
    end

    if app.sprite.colorMode ~= ColorMode.INDEXED then
        app.alert("Please change color mode to indexed.")
        return
    end

    local file_path = openFileDialog()
    if file_path == nil then
        return
    end

    if openExportSpritesheetDialog() == false then
        return
    end

    create_indexed_image(file_path)
end

function openFileDialog()
    local stop_script = true

    local dlg = Dialog {
        title = "Export image as spritesheet"
    }

    local file_path = dlg:label {
        text = "Select the file path below and do NOT change the output file in the next dialog!!"
    }:file {
        id = "file_path",
        label = "Output File:",
        save = true,
        filename = "spritesheet.png",
        filetypes = { "png" },
        entry = true
    }:button { id = "confirm", text = "Confirm", onclick = function()
        stop_script = false
        dlg:close()
    end
    }:button { id = "cancel", text = "Cancel", onclick = function()
        dlg:close()
    end
    }:show {
        wait = true,
    }.data["file_path"]

    if stop_script then
        return nil
    end

    return file_path
end

function openExportSpritesheetDialog()
    os.remove(TMP_FILE_PATH)

    local res = app.command.ExportSpriteSheet({
        textureFilename = TMP_FILE_PATH
    })

    return app.fs.isFile(TMP_FILE_PATH)
end

function create_indexed_image(file_path)
    -- Stolen from here https://github.com/mikeemm/aseprite-index-exporter/tree/master
    local currentSprite = app.open(TMP_FILE_PATH)

    local exportImageSpecs = currentSprite.spec
    exportImageSpecs.colorMode = ColorMode.GRAY
    local exportImage = Image(exportImageSpecs)
    local sourceImage = Image(currentSprite.spec)
    sourceImage:drawSprite(currentSprite, 1)
    local pc = app.pixelColor
    for it in sourceImage:pixels() do
        local index = it()
        exportImage:drawPixel(it.x, it.y, pc.graya(it()))
    end

    exportImage:saveAs(file_path)
    app.alert(string.format("Spritesheet exported to '%s'.", file_path))
    app.command.CloseFile()
end

main()
