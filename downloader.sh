#!/bin/bash

# Lista de paquetes requeridos.
REQUIRED_PACKAGES=("curl" "wget" "unzip" "lynx")

SCRIPT_NAME=$(basename "$0")

# Definir ruta de descarga
if [ -d "/roms2/tools" ]; then
	TOOLS_DEST="/roms2/tools/"
elif [ -d "/roms/tools" ]; then
	TOOLS_DEST="/roms/tools/"
else
    echo "❌ No se encontró ninguna de las rutas /roms2/tools ni /roms/tools."
    exit 1
fi

SCRIPT_URL="https://raw.githubusercontent.com/kemazon/RomsDownloader/refs/heads/main/downloader.sh"
SCRIPT_DESTINO="$TOOLS_DEST/$SCRIPT_NAME"

GPTK_URL="https://raw.githubusercontent.com/kemazon/RomsDownloader/refs/heads/main/downloader.gptk"
GPTK_DEST="/opt/inttools/downloader.gptk"

RC_URL="https://raw.githubusercontent.com/kemazon/RomsDownloader/refs/heads/main/.lynxrc"
RC_DEST="/home/ark/.lynxrc"

CFG_URL="https://raw.githubusercontent.com/kemazon/RomsDownloader/refs/heads/main/lynx.cfg"
CFG_DEST="/etc/lynx/lynx.cfg"

sudo chmod u+s $(which ping)

# Verifica conexión a internet
check_internet() {
    if ping -c 1 8.8.8.8 &>/dev/null || ping -c 1 1.1.1.1 &>/dev/null; then
        echo "✔ Conexión a internet disponible."
        return 0
    else
        echo "✖ No hay conexión a internet. No se puede continuar."
		sleep 5
        exit 1
    fi
}

# Verifica e instala paquetes según la distribución
install_packages() {
    for package in "${REQUIRED_PACKAGES[@]}"; do
        if ! command -v "$package" &>/dev/null; then
            echo "⚠ El paquete '$package' no está instalado. Instalando..."
            if [[ -f /etc/debian_version ]]; then
                sudo apt update && sudo apt install -y "$package"
            elif [[ -f /etc/arch-release ]]; then
                sudo pacman -Sy --noconfirm "$package"
            else
                echo "❌ No se pudo determinar la distribución. Instale '$package' manualmente."
                exit 1
            fi
        else
            echo "✔ '$package'"
        fi
    done
}

update_script() {
	REMOTE_HASH=$(curl -sL "$SCRIPT_URL" | sha1sum | awk '{print $1}')
	echo $REMOTE_HASH
	LOCAL_HASH=$(sha1sum "$TOOLS_DEST/$SCRIPT_NAME" | awk '{print $1}')
	echo $LOCAL_HASH
	
	if [ "$REMOTE_HASH" != "$LOCAL_HASH" ]; then
		echo "⚠️  Hay una versión más reciente disponible en GitHub."
		sleep 5
	else
		echo "✅  El script está actualizado."
		sleep 5
fi
}

# Descarga el script si todo está bien
# download_script() {
    # echo "⬇ Descargando script desde $SCRIPT_URL..."
    # wget -O "$SCRIPT_DEST" "$SCRIPT_URL" || curl -o "$SCRIPT_DEST" "$SCRIPT_URL"
	# wget -O "$GPTK_DEST" "$GPTK_URL" || curl -o "$GPTK_DEST" "$GPTK_URL"
	# wget -O "$RC_DEST" "$RC_URL" || curl -o "$RC_DEST" "$RC_URL"
	# sudo wget -O "$CFG_DEST" "$CFG_URL" || sudo curl -o "$CFG_DEST" "$CFG_URL"
    # chmod +x "$SCRIPT_DEST"
    # echo "✔ Script descargado y marcado como ejecutable en $SCRIPT_DEST."
	# echo "✔ INSTALACIÓN COMPLETA, REINICIANDO."
	# sleep 4
	# sudo systemctl restart emulationstation
# }

# Ejecutar funciones
check_internet
install_packages
update_script
