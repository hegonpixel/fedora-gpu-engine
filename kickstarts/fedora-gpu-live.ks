# fedora-gpu-live.ks - Fedora Live con soporte GPU out-of-the-box
version=F40

# Configuración básica del sistema
lang en_US.UTF-8
keyboard us
timezone UTC
selinux --enforcing
firewall --enabled --service=mdns

# Repositorios oficiales de Fedora
url --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=fedora --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-$releasever&arch=$basearch
repo --name=updates --mirrorlist=https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f$releasever&arch=$basearch

# Repositorios RPM Fusion (Drivers NVIDIA, códecs y aceleración por hardware)
repo --name=rpmfusion-free --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-free-updates --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=free-fedora-updates-released-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-$releasever&arch=$basearch
repo --name=rpmfusion-nonfree-updates --mirrorlist=https://mirrors.rpmfusion.org/mirrorlist?repo=nonfree-fedora-updates-released-$releasever&arch=$basearch

%packages
# Entorno base y Kernel
@core
@standard
kernel
kernel-modules-extra
kernel-devel
dkms

# Herramientas de diagnóstico de GPU
pciutils
lshw
glx-utils
vulkan-tools
clinfo
nvtop
btop

# Soporte AMD / Intel Mesa y Vulkan
mesa-dri-drivers
mesa-vulkan-drivers
vulkan-loader
libva-utils

# Drivers propietarios NVIDIA y CUDA (vía RPM Fusion Nonfree)
akmod-nvidia
xorg-x11-drv-nvidia
xorg-x11-drv-nvidia-cuda
xorg-x11-drv-nvidia-cuda-libs
xorg-x11-drv-nvidia-power

# Utilidades Live
@base-x
liveusb-utils
%end

%post
# Configurar parámetros del kernel para NVIDIA
# Deshabilitar nouveau en favor del driver propietario
cat << 'EOF' > /etc/modprobe.d/blacklist-nouveau.conf
blacklist nouveau
options nouveau modeset=0
EOF

# Habilitar servicios de suspensión y energía de NVIDIA
systemctl enable nvidia-suspend.service || true
systemctl enable nvidia-hibernate.service || true
systemctl enable nvidia-resume.service || true

# Verificación de compilación de módulos akmods en el primer arranque
systemctl enable akmods.service || true
%end
