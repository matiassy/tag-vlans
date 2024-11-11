#!/bin/bash

# Función para mostrar las interfaces disponibles
function mostrar_interfaces() {
    interfaces=($(ip -o link show | awk -F': ' '$2 != "lo" {print $2}'))
    echo "Seleccione una interfaz:"
    for i in "${!interfaces[@]}"; do
        echo "$((i + 1)) - ${interfaces[i]}"
    done
}

# Pregunta al usuario si quiere levantar o bajar una VLAN
echo "¿Qué deseas hacer?"
echo "1 - Levantar una VLAN"
echo "2 - Bajar una VLAN"
read -p "Selecciona una opción (1 o 2): " accion

if [[ "$accion" == "1" ]]; then
    # Opción para levantar una VLAN
    mostrar_interfaces
    read -p "Ingrese el número de la interfaz: " iface_num
    iface="${interfaces[$((iface_num - 1))]}"

    if [[ -z "$iface" ]]; then
        echo "Selección inválida."
        exit 1
    fi

    # Solicita el número de VLAN
    read -p "Ingrese el número de VLAN: " vlan_id

    # Solicita la dirección IP
    read -p "Ingrese la dirección IP (ejemplo 10.5.5.110/24): " ip_addr

    # Agrega la interfaz VLAN
    sudo ip link add link "$iface" name "$iface.$vlan_id" type vlan id "$vlan_id"
    sudo ip addr add "$ip_addr" dev "$iface.$vlan_id"
    sudo ip link set dev "$iface.$vlan_id" up

    echo "Interfaz $iface.$vlan_id configurada con la IP $ip_addr y levantada."

elif [[ "$accion" == "2" ]]; then
    # Opción para bajar una VLAN
    mostrar_interfaces
    read -p "Ingrese el número de la interfaz: " iface_num
    iface="${interfaces[$((iface_num - 1))]}"

    if [[ -z "$iface" ]]; then
        echo "Selección inválida."
        exit 1
    fi

    # Solicita el número de VLAN
    read -p "Ingrese el número de VLAN que desea bajar: " vlan_id

    # Baja y elimina la interfaz VLAN
    sudo ip link set dev "$iface.$vlan_id" down
    sudo ip link delete "$iface.$vlan_id"

    echo "Interfaz $iface.$vlan_id bajada y eliminada."

else
    echo "Opción inválida. Seleccione 1 o 2."
    exit 1
fi
