import os
import tkinter as tk
from tkinter import filedialog, ttk, messagebox
from PIL import Image
import imageio.v3 as iio

class HEICConverterApp(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("HEIC CVIBA CONVERT")
        self.geometry("500x300")
        #self.iconbitmap("icon.ico")


        # Directory selection
        self.label_dir = tk.Label(self, text="Select directory:")
        self.label_dir.pack(pady=5)

        self.entry_dir = tk.Entry(self, width=50)
        self.entry_dir.pack(pady=5)

        self.button_browse = tk.Button(self, text="Browse", command=self.browse_directory)
        self.button_browse.pack(padx=5)
        #self.button_browse.place(x=410, y=30)
 

        # Format selection
        self.label_format = tk.Label(self, text="Select output format:")
        self.label_format.pack(pady=5)

        self.format_var = tk.StringVar(value="jpeg")
        self.dropdown_format = ttk.Combobox(self, textvariable=self.format_var, values=["jpeg", "jpg", "png", "bmp", "tiff"])
        self.dropdown_format.pack(pady=5)

        # Progress bar
        self.progress = ttk.Progressbar(self, orient="horizontal", length=400, mode="determinate")
        self.progress.pack(pady=20)

        # Conversion status
        self.status_text = tk.StringVar()
        self.label_status = tk.Label(self, textvariable=self.status_text)
        self.label_status.pack(pady=5)

        # Convert button
        self.button_convert = tk.Button(self, text="Convert", command=self.convert_images)
        self.button_convert.pack(pady=5)

    def browse_directory(self):
        directory = filedialog.askdirectory()
        if directory:
            self.entry_dir.delete(0, tk.END)
            self.entry_dir.insert(0, directory)

    def convert_images(self):
        directory = self.entry_dir.get()
        if not directory:
            messagebox.showwarning("Input Error", "Please select a directory")
            return
        
        output_format = self.format_var.get()
        heic_files = [f for f in os.listdir(directory) if f.lower().endswith(".heic")]

        if not heic_files:
            messagebox.showinfo("No Files", "No HEIC files found in the selected directory")
            return
        
        self.progress["maximum"] = len(heic_files)
        self.progress["value"] = 0

        for idx, heic_file in enumerate(heic_files):
            try:
                self.status_text.set(f"Converting {heic_file} ({idx+1}/{len(heic_files)})...")
                self.update_idletasks()

                heic_path = os.path.join(directory, heic_file)
                image = iio.imread(heic_path)

                output_file = os.path.splitext(heic_file)[0] + f".{output_format}"
                output_path = os.path.join(directory, output_file)
                image_pil = Image.fromarray(image)
                image_pil.save(output_path, format=output_format.upper())

                self.progress["value"] += 1
                self.update_idletasks()

            except Exception as e:
                messagebox.showerror("Conversion Error", f"Failed to convert {heic_file}: {e}")

        self.status_text.set("Conversion complete!")
        messagebox.showinfo("Success", "All files have been converted successfully")

if __name__ == "__main__":
    app = HEICConverterApp()
    app.mainloop()
