# OneFixer

OneFixer es una herramienta para eliminar claves duplicadas de OneDrive en el registro de Windows.

---

## 🚀 **Características**
- **Backup Automático:** Crea un archivo `.reg` con un respaldo de las claves afectadas antes de eliminarlas.
- **Detección Automática:** Encuentra claves duplicadas relacionadas con OneDrive en el registro.
- **Cierre de OneDrive:** Detiene automáticamente el proceso de OneDrive si está activo.
- **Reinicio Seguro:** Reinicia el Explorador de Windows para aplicar los cambios de manera segura.
- **Mensajes Informativos:** Proporciona información detallada de cada paso del proceso.

---

## 📋 **Requisitos**
1. **Permisos de Administrador.**
2. **Sistema Operativo:** Windows 10 o superior.
3. **OneDrive Instalado.**

---

## 🛠️ **Instrucciones**
1. **Descarga el Script:**  
   Descarga el archivo `OneFixer.vbs` de este repositorio.

2. **Ejecuta el Script:**  
   Haz doble clic sobre el archivo `OneFixer.vbs`. El script solicitará permisos de administrador si no los tienes.

3. **Proceso Automático:**
   - Cierra OneDrive si está ejecutándose.
   - Realiza un respaldo de las claves duplicadas en el archivo `backup.reg`.
   - Elimina las claves duplicadas en el registro.
   - Reinicia el Explorador de Windows.

4. **Resultado:**
   - Si hay claves duplicadas, serán eliminadas y el script notificará el éxito de la operación.
   - Si no se encuentran duplicados, se informará al usuario.

---

## ⚠️ **Advertencias**
- Este script realiza cambios en el Registro de Windows. Es recomendable hacer un respaldo completo antes de ejecutarlo.
- OneFixer se proporciona "tal cual", sin garantía alguna. Úsalo bajo tu propio riesgo.

---

## 📂 **Estructura del Backup**
El archivo `backup.reg` contiene un respaldo de las claves duplicadas antes de su eliminación. Su estructura es la siguiente:

```
Windows Registry Editor Version 5.00

[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{ClaveDuplicada}]
```

Cada clave duplicada identificada se guardará en este archivo de respaldo antes de ser eliminada por el script.

---

## 📜 **Licencia**
Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más información.
