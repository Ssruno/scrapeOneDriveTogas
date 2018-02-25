require 'pincers' #https://github.com/Ssruno/pincers/commit/aa3c62d0b43aba0eeccf3f30d511d7b09a9f5e72
require 'byebug'



def traerCelda(_foto, _pincers)
    # Hay varias llamadas al parent_jq por que primero lo implemente con thumbnails, 
    # luego lo cambié pero como ya obtuve lo que necesitaba, lo dejo así.
    _pincers.search( content: _foto ).wait(:present, timeout: 120.0 ).parent_jq.parent_jq.parent_jq.parent_jq.parent_jq.parent_jq.parent_jq.parent_jq
end

def marcarFoto(_foto, _pincers)
  # Lo necesario para que salga el checkbox al final
  celda = traerCelda(_foto, _pincers)
  foto = celda.search(tag: 'div', class: 'ms-DetailsRow-check')      
  celda.hover
  foto.click
end

def cambiarFormatoLista(_estilo, _pincers)        
    _pincers.search(tag: 'i', class: 'od-IconGlyph ms-Icon ms-Icon--ViewAll css-36 od-IconGlyph--visible' ).wait(:present, timeout: 120.0 ).click
    sleep(2)
    _pincers.search(tag: 'span', class: 'ms-ContextualMenu-itemText', content: _estilo ).wait(:present, timeout: 120.0 ).click
end

def cambiarOrden(_orden, _pincers)
    _pincers.search(tag: 'i', class: 'od-IconGlyph ms-Icon ms-Icon--SortLines css-39 od-IconGlyph--visible' ).wait(:present, timeout: 120.0 ).click
    sleep(2)
    _pincers.search(tag: 'span', class: 'ms-ContextualMenu-itemText', content: _orden ).wait(:present, timeout: 120.0 ).click
end

def downloadFoto(_pincers)
  _pincers.search(tag: 'span', content: 'Download').wait(:present, timeout: 120.0 ).click
  sleep(20)
end

def existeFoto(_foto, _pincers)    
    celda = _pincers.search( content: _foto )    
    if celda.to_html != ""
        puts "Existe la foto"    
        return true
    else 
        puts "No existe la foto"
        return false
    end    
end

def scrollToFoto(_foto, _pincers)
    celda = _pincers.search( content: _foto ).wait(:present, timeout: 120.0 ).elements.first.location_once_scrolled_into_view
end

def scrollUltimoElemento(_pincers)
    _pincers.search( class: 'ms-List-cell' ).wait(:present, timeout: 120.0 ).elements.last.location_once_scrolled_into_view    
end

def scrollUltimalista(_pincers)    
    _pincers.search( class: 'ms-List-page' ).wait(:present, timeout: 120.0 ).elements.last.location_once_scrolled_into_view    
end

def esperamos(_segundos, _mensaje)
    puts "#{_mensaje}, esperamos #{_segundos} segundos"
    sleep(_segundos)
end

def downloadFotosFromFolder(_listaDeFotos, _pincers)
    _listaDeFotos.each do |foto|
    while !existeFoto(foto, _pincers) do
        scrollUltimalista(_pincers)        
        # Esperamos un ratito
        esperamos(15, "Hacemos un scroll")
    end
    scrollToFoto(foto, _pincers)
    marcarFoto(foto, _pincers)
    downloadFoto(_pincers)
    esperamos(5, "Descargamos la foto #{foto}")
    marcarFoto(foto, _pincers)
  end
end

def irAlaCarpeta(_folder, _pincers)
    _pincers.search( content: _folder ).click
end

def volverAlaCarpetaRoot(_pincers)
    _pincers.search( content: "POLITECNICA UNA 2017").click
end

def downloadFotosFromURL(_fotosAndFolders, _url)

    Pincers.for_webdriver  :chrome do |pincers|
        pincers.goto _url

        esperamos(15, "Abrimos la pagina principal")
        cambiarFormatoLista("Compact list", pincers)
        esperamos(10, "Esperamos que la lista compacta se actualice")
  

        _fotosAndFolders.each do |folder,fotosLista|
            irAlaCarpeta(folder, pincers)
            esperamos(10, "Ingresamos a #{folder}")
        
            cambiarOrden("Name", pincers)
            esperamos(12, "Esperamos que la lista ordenada se actualice")
            cambiarOrden("Descending", pincers)
            esperamos(12, "Esperamos que la lista DESCENDENTE se actualice") 

            downloadFotosFromFolder(fotosLista.split(','), pincers)

            volverAlaCarpetaRoot(pincers)
            esperamos(10, "Volvemos a la carpeta root")
        end

    end

end

#==================================================
fotosHash = {
    "1_SESION" => "IMG_6589.jpg,IMG_6336.jpg,IMG_6334.jpg,_DSC7989.jpg,_DSC7986.jpg,_DSC7983.jpg,_DSC7980.jpg,_DSC7974.jpg,_DSC7969.jpg,_DSC7966.jpg,_DSC7965.jpg,_DSC7964.jpg,_DSC7961.jpg,_DSC7959.jpg,_DSC7956.jpg,_DSC7953.jpg",
    "2_SESION" => "DSC_0696.jpg,DSC_0693.jpg,DSC_0691.jpg,DSC_0687.jpg,DSC_0685.jpg,DSC_0682.jpg,DSC_0681.jpg",
    "3_SESION" => "DSC_7324.jpg",
    "4_MISA" => "DSC_0722.jpg,DSC_0563.jpg,DSC_0502.jpg,DSC_0306.jpg,DSC_0305.jpg,_AG_1729.jpg,_AG_1727.jpg",
    "5_MISA" => "_ALC0754.jpg,_ALC0752.jpg,_ALC0748.jpg,_ALC0747.jpg,_ALC0744.jpg,_ALC0743.jpg,_ALC0649.jpg",
    "10_ENTREGA" => "IMG_0306.jpg,DIE_6035.jpg,DIE_6034.jpg,DIE_6033.jpg,DIE_6032.jpg",
    "11_ENTREGA" => "DSC_5194.jpg,AAG_2589.jpg,AAG_2588.jpg,AAG_2587.jpg,AAG_2586.jpg,AAG_2585.jpg,AAG_2584.jpg,AAG_2583.jpg,AAG_2582.jpg",
    "12_ENTREGA" => "_MG_7577.jpg,_MG_7576.jpg,_MG_7575.jpg",
    "15_POS-ENTREGA" => "DIE_6718.jpg,DIE_6716.jpg,DIE_6714.jpg"
}

url="URL of the SHARED FOLDER"

downloadFotosFromURL(fotosHash, url)
#==================================================




