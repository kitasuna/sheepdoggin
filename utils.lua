function exportPalette()
  local saved_pal = {}
  for addr=0x5f00,0x5f1f do 
    saved_pal[addr] = peek(addr)
  end
  return saved_pal
end

-- caution: potential for palette disaster
function importPalette(p)
  for addr=0x5f00,0x5f1f do
    poke(addr, p[addr])
  end
end
