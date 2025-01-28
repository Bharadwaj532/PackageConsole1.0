using Microsoft.Win32;
using System.Diagnostics;
using System.Numerics;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using NLog;
using System.Windows.Media.Animation;
using System.IO;

public partial class App : Application
{
    private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);
        Logger.Info("Application started");
    }

    protected override void OnExit(ExitEventArgs e)
    {
        Logger.Info("Application exited");
        base.OnExit(e);
    }
}

namespace PackageConsole
{
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        public string ProductName { get; set; }
        public string FileVersion { get; set; }
        private TextBox filePathTextBox;
        private TextBox fileNameTextBox;
        private TextBox fileVersionTextBox;
        private TextBox productNameTextBox;
        private TextBox vendorTextBox;
        private TextBox productCodeTextBox;
        private TextBox appKeyIDTextBox;
        private TextBox drmBuildTextBox;
        private TextBox RequestIDTextBox;
        private TextBox AppKeyIDTextBox;
        private TextBox DRMBUILDTextBox;
        private string selectedRebootOption = "No";
        private static readonly Logger Logger = LogManager.GetCurrentClassLogger();

        public MainWindow()
        {
            InitializeComponent();
            LoadUserDetails();
            
        }
        private void Window_Loaded(object sender, RoutedEventArgs e)
        {
            StartMarquee();
        }
        private void StartMarquee()
        {
            double from = MainContentArea.ActualWidth;
            double to = -MarqueeText.ActualWidth;

            DoubleAnimation marqueeAnimation = new DoubleAnimation
            {
                From = from,
                To = to,
                Duration = new Duration(TimeSpan.FromSeconds(10)),
                RepeatBehavior = RepeatBehavior.Forever
            };

            MarqueeText.BeginAnimation(Canvas.LeftProperty, marqueeAnimation);
        }

        private void LoadUserDetails()
        {
            // Simulate fetching the logged-in user's name
            string username = System.Security.Principal.WindowsIdentity.GetCurrent().Name; // Replace with actual logic to get the username
            UserDetails.Text = $"Welcome, {username}";
            Logger.Info($"IniConsolePage initialized by the user : {username} ");

        }
        private void Logout_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Logged out successfully!");
            // Add your logout logic here
        }
        private void SidebarToggle_Click(object sender, RoutedEventArgs e)
        {
            Sidebar.Visibility = Sidebar.Visibility == Visibility.Visible ? Visibility.Collapsed : Visibility.Visible;
        }

        private void AddPackage_Click(object sender, RoutedEventArgs e)
        {
            Logger.Info($"Selected the Add Package Page");
            Sidebar.Visibility = Visibility.Hidden;
            if (MainContentArea is Grid mainGrid)
            {
                mainGrid.Children.Clear();
                mainGrid.Children.Add(CreateAddPackageForm());
            }
        }

        private UIElement CreateAddPackageForm()
        {
            var stackPanel = new StackPanel();

            // Upload Installer Button
            var uploadButton = new Button
            {
                Content = "Upload Installer",
                Width = 120,
                Height = 30,
                Margin = new Thickness(10)
            };
            uploadButton.Click += UploadInstallerButton_Click;
            stackPanel.Children.Add(new StackPanel
            {
                Orientation = Orientation.Horizontal,
                RenderTransformOrigin = new System.Windows.Point(0.503, -0.549),
                Children = { uploadButton }
            });

            // Add Form Fields
            stackPanel.Children.Add(CreateLabeledTextBox("Request ID:", "RequestIDTextBox", out RequestIDTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("File Path:", "FilePathTextBox", out filePathTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("File Name:", "FileNameTextBox", out fileNameTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("File Version:", "FileVersionTextBox", out fileVersionTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("Product Name:", "ProductNameTextBox", out productNameTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("Vendor:", "VendorTextBox", out vendorTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("Product Code:", "ProductCodeTextBox", out productCodeTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("Appkey ID Code:", "AppKeyIDTextBox", out appKeyIDTextBox));
            stackPanel.Children.Add(CreateLabeledTextBox("DRM Build:", "DRMBUILDTextBox", out drmBuildTextBox));

            // Horizontal Panel for Upgrade Section
            var upgradePanel = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(0, 20, 0, 10)
            };

            // Upgrade Label
            upgradePanel.Children.Add(new TextBlock
            {
                Text = "Upgrade Available:",
                Margin = new Thickness(0, 0, 10, 0),
                FontWeight = FontWeights.Normal,
                Foreground = Brushes.White,
                VerticalAlignment = VerticalAlignment.Center
            });

            // Radio Buttons
            var yesRadioButton = new RadioButton
            {
                Content = "Yes",
                GroupName = "UpgradeOptions",
                Margin = new Thickness(10, 0, 10, 0),
                Foreground = Brushes.White,
                VerticalAlignment = VerticalAlignment.Center
            };

            var noRadioButton = new RadioButton
            {
                Content = "No",
                GroupName = "UpgradeOptions",
                Margin = new Thickness(10, 0, 10, 0),
                Foreground = Brushes.White,
                VerticalAlignment = VerticalAlignment.Center,
                IsChecked = true // Default to "No"
            };

            // Upload INI Button (Initially Hidden)
            var uploadINIButton = new Button
            {
                Content = "Upload INI File",
                Width = 150,
                Height = 20,
                Margin = new Thickness(10, 0, 0, 0),
                Visibility = Visibility.Collapsed
            };
            uploadINIButton.Click += (s, e) =>
            {
                var openFileDialog = new Microsoft.Win32.OpenFileDialog
                {
                    Filter = "INI Files (*.ini)|*.ini",
                    Title = "Select an INI File"
                };

                if (openFileDialog.ShowDialog() == true)
                {
                    string selectedFilePath = openFileDialog.FileName;

                    // Ensure Log folder exists
                    string logFolderPath = "Logs";
                    Directory.CreateDirectory(logFolderPath);

                    // Save as tempUpgrade.ini
                    string destinationPath = System.IO.Path.Combine(logFolderPath, "tempUpgrade.ini");
                    File.Copy(selectedFilePath, destinationPath, true);

                    MessageBox.Show($"INI file uploaded successfully to: {destinationPath}");
                }
                else
                {
                    MessageBox.Show("No file selected.");
                }
            };

            // Toggle Upload INI Button Visibility Based on Radio Selection
            yesRadioButton.Checked += (s, e) => { uploadINIButton.Visibility = Visibility.Visible; };
            noRadioButton.Checked += (s, e) => { uploadINIButton.Visibility = Visibility.Collapsed; };

            // Add Radio Buttons and Upload Button to Panel
            upgradePanel.Children.Add(yesRadioButton);
            upgradePanel.Children.Add(noRadioButton);
            upgradePanel.Children.Add(uploadINIButton);

            // Add Upgrade Panel to Main StackPanel
            stackPanel.Children.Add(upgradePanel);

            // Horizontal Panel for Reboot Required Section
            var sliderLabelsPanel = new StackPanel
            {
                Orientation = Orientation.Horizontal,
                HorizontalAlignment = HorizontalAlignment.Stretch,
                Margin = new Thickness(0, 20, 0, 10)
            };

            // Reboot Label
            sliderLabelsPanel.Children.Add(new TextBlock
            {
                Text = "Reboot Required:",
                Margin = new Thickness(0, 0, 10, 0),
                FontWeight = FontWeights.Normal,
                Foreground = Brushes.White,
                VerticalAlignment = VerticalAlignment.Center
            });

            // Create a Grid to align labels and the slider
            var grid = new Grid();
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // For labels
            grid.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto }); // For the slider

            var labels = new[] { "Install", "Uninstall", "Always", "No" };
            for (int i = 0; i < labels.Length; i++)
            {
                sliderLabelsPanel.Children.Add(new TextBlock
                {
                    Text = labels[i],
                    Foreground = System.Windows.Media.Brushes.White,
                    HorizontalAlignment = HorizontalAlignment.Center,
                    Margin = new Thickness(10, 0, 20, 0),
                    Width = 50 // Adjust width for proper spacing
                });
            }

            grid.Children.Add(sliderLabelsPanel);
            Grid.SetRow(sliderLabelsPanel, 0);

            // Create the slider
            var slider = new Slider
            {
                Minimum = 0,
                Maximum = 3,
                TickFrequency = 1,
                IsSnapToTickEnabled = true,
                Width = 300,
                Margin = new Thickness(100, 5, 0, 10),
                HorizontalAlignment = HorizontalAlignment.Left
            };

            slider.ValueChanged += (s, e) =>
            {
                int value = (int)slider.Value;
                selectedRebootOption = labels[value]; // Update selected option
            };

            // Set default value
            slider.Value = 3; // Default to "No"
            selectedRebootOption = "No";

            grid.Children.Add(slider);
            Grid.SetRow(slider, 1);

            // Add grid to the stackPanel instead of rebootPanel
            stackPanel.Children.Add(grid);
            // Submit and Clear Buttons
            var submitButton = new Button
            {
                Content = "Submit",
                Width = 150,
                Height = 30,
                Margin = new Thickness(10)
            };
            submitButton.Click += SubmitButton_Click;

            var clearButton = new Button
            {
                Content = "Clear",
                Width = 150,
                Height = 30,
                Margin = new Thickness(10)
            };
            clearButton.Click += ClearButton_Click;

            stackPanel.Children.Add(new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(20, 30, 20, 10),
                Children = { submitButton, clearButton }
            });

            return stackPanel;
        }

        private StackPanel CreateLabeledTextBox(string labelText, string textBoxName, out TextBox textBox)
        {
            textBox = new TextBox
            {
                Name = textBoxName,
                Width = 300
            };

            return new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(5),
                Children =
                {
                    new TextBlock
                    {
                        Text = labelText,
                        Width = 100,
                        Foreground = System.Windows.Media.Brushes.White,
                        VerticalAlignment = VerticalAlignment.Center
                    },
                    textBox
                }
            };
        }
        private void UploadInstallerButton_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog
            {
                Filter = "Installer Files (*.msi;*.exe)|*.msi;*.exe",
                Title = "Select an Installer File"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                string fullFilePath  = openFileDialog.FileName;
                string filedirectoryPath = System.IO.Path.GetDirectoryName(fullFilePath);
                fileNameTextBox.Text = System.IO.Path.GetFileName(openFileDialog.FileName);
                filePathTextBox.Text = filedirectoryPath;

                try
                {
                    if (System.IO.Path.GetExtension(openFileDialog.FileName).Equals(".msi", StringComparison.OrdinalIgnoreCase))
                    {
                        // Use Windows Installer COM object to read MSI properties
                        var installerType = Type.GetTypeFromProgID("WindowsInstaller.Installer");
                        dynamic installer = Activator.CreateInstance(installerType);
                        var database = installer.OpenDatabase(openFileDialog.FileName, 0);
                        fileVersionTextBox.Text = GetMsiProperty(database, "ProductVersion");
                        productNameTextBox.Text = GetMsiProperty(database, "ProductName");
                        vendorTextBox.Text = GetMsiProperty(database, "Manufacturer");
                        productCodeTextBox.Text = GetMsiProperty(database, "ProductCode");
                    }
                    else
                    {
                        var fileVersionInfo = FileVersionInfo.GetVersionInfo(openFileDialog.FileName);
                        fileVersionTextBox.Text = fileVersionInfo.FileVersion;
                        productNameTextBox.Text = fileVersionInfo.ProductName;
                        vendorTextBox.Text = fileVersionInfo.CompanyName;
                        productCodeTextBox.Text = fileVersionInfo.ProductVersion;
                    }
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error reading file properties: {ex.Message}");
                }
            }
        }

        private string GetMsiProperty(dynamic database, string property)
        {
            var view = database.OpenView($"SELECT `Value` FROM `Property` WHERE `Property` = '{property}'");
            view.Execute();
            var record = view.Fetch();
            return record?.StringData(1);
        }


        private StackPanel CreateLabeledTextBox(string labelText, string textBoxName)
        {
            return new StackPanel
            {
                Orientation = Orientation.Horizontal,
                Margin = new Thickness(5),
                Children =
                {
                    new TextBlock
                    {
                        Text = labelText,
                        Width = 100,
                        VerticalAlignment = VerticalAlignment.Center
                    },
                    new TextBox
                    {
                        Name = textBoxName,
                        Width = 300
                    }
                }
            };
        }

        private void SubmitButton_Click(object sender, RoutedEventArgs e)
        {
            try
            {
                // Step 1: Create the folder structure in C:\Temp\PackageConsole
                string basePath = @"C:\Temp\PackageConsole";
                string productName = productNameTextBox.Text.Trim(); // Ensure no duplicates
                string productVersion = fileVersionTextBox.Text.Trim(); // Ensure no duplicates
                string filePath = filePathTextBox.Text ?? string.Empty;
                string fileName = fileNameTextBox.Text ?? string.Empty;
                string fileVersion = fileVersionTextBox.Text ?? string.Empty;
               // string productName = productNameTextBox.Text ?? string.Empty;
                string vendor = vendorTextBox.Text ?? string.Empty;
                string productCode = productCodeTextBox.Text ?? string.Empty;
                string appKeyID = appKeyIDTextBox.Text ?? string.Empty;
                string drmBuild = drmBuildTextBox.Text ?? string.Empty;

                if (string.IsNullOrWhiteSpace(productName) || string.IsNullOrWhiteSpace(productVersion))
                {
                    MessageBox.Show("Product Name or Version cannot be empty.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                string productFolder = System.IO.Path.Combine(basePath, productName, productVersion, "Altiris");
                
                string supportFilesFolder = System.IO.Path.Combine(productFolder, "1.0", "SupportFiles");

                // Create directories
                Directory.CreateDirectory(productFolder);
                
                //Directory.CreateDirectory(supportFilesFolder);

                // Step 2: Copy Toolkit folder to the new folder
                string toolkitSourcePath = @"\\SankaraSubrahmanyam-PC\D$\Files\Toolkit"; // Replace with your actual Toolkit folder path
                string toolkitDestinationPath = System.IO.Path.Combine(productFolder, "1.0");
                string filesFolder = System.IO.Path.Combine(toolkitDestinationPath, "Files");
                Directory.CreateDirectory(filesFolder);

                if (Directory.Exists(toolkitSourcePath))
                {
                    CopyDirectory(toolkitSourcePath, toolkitDestinationPath);
                }
                else
                {
                    MessageBox.Show($"Toolkit folder not found at: {toolkitSourcePath}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }

                // Step 3: Copy the folder from Source (FilePath) to Files folder
                string sourcePath = filePathTextBox.Text.Trim();

                if (Directory.Exists(sourcePath))
                {
                    CopyDirectory(sourcePath, filesFolder);
                }
                else
                {
                    MessageBox.Show($"Source folder not found at: {sourcePath}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                    return;
                }
               
                string rebootRequired = GetRebootRequired();
               // MessageBox.Show($"Reboot Required: {rebootRequired}", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
                // Step 4: Create tmpPackage.ini and place it in SupportFiles folder
                string iniFilePath = System.IO.Path.Combine(supportFilesFolder, "tmpPackage.ini");
                using (var writer = new StreamWriter(iniFilePath))
                {
                    writer.WriteLine("[PRODUCT INFO]");
                    writer.WriteLine($"APPVENDOR={vendor}");
                    writer.WriteLine($"APPNAME={productName}");
                    writer.WriteLine($"APPVER={fileVersion}");
                    writer.WriteLine($"APPKEYID={appKeyID}");
                    writer.WriteLine($"DRMBUILD={drmBuild}");
                    writer.WriteLine($"APPGUID={productCode}");
                    // Add more key-value pairs as needed
                    writer.WriteLine($"REBOOTER={rebootRequired}");
                    writer.WriteLine();

                    writer.WriteLine("[INSTALL1]");
                    writer.WriteLine($"NAME={productName}");
                    writer.WriteLine($"VER={fileVersion}");
                    writer.WriteLine($"GUID={productCode}");
                    writer.WriteLine();

                    writer.WriteLine("[UNINSTALL1]");
                    writer.WriteLine($"NAME={productName}");
                    writer.WriteLine($"VER={fileVersion}");
                    writer.WriteLine($"GUID={productCode}");
                    writer.WriteLine();

                    // Step 5: Handle Upgrade sections if Upgrade is selected
                    if (UpgradeRadioButtonIsYes()) // Check if the Upgrade radio button is YES
                    {
                        string uploadedIniFilePath = @"Logs\tempUpgrade.ini"; // Path to the uploaded INI file
                        if (File.Exists(uploadedIniFilePath))
                        {
                            var upgradeSections = ParseUpgradeSections(uploadedIniFilePath);
                            foreach (var section in upgradeSections)
                            {
                                writer.WriteLine($"[{section.Key}]");
                                foreach (var kvp in section.Value)
                                {
                                    writer.WriteLine($"{kvp.Key}={kvp.Value}");

                                }
                                writer.WriteLine();
                            }
                        }
                        else
                        {
                            MessageBox.Show("Upgrade INI file not found. Please upload the file.", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
                        }
                    }
                }

                // Show success message
                MessageBox.Show($"Package setup completed successfully at: {productFolder}", "Success", MessageBoxButton.OK, MessageBoxImage.Information);
            }
            catch (Exception ex)
            {
                // Log and show error
                MessageBox.Show($"An error occurred: {ex.Message}", "Error", MessageBoxButton.OK, MessageBoxImage.Error);
            }
        }

        // Helper to check if Upgrade radio button is YES
        private bool UpgradeRadioButtonIsYes()
        {
            // Logic to determine if the Upgrade radio button is set to YES
            return true; // Replace with actual check for your radio button
        }

        // Helper to parse UPGRADE sections from an INI file
        private Dictionary<string, Dictionary<string, string>> ParseUpgradeSections(string iniFilePath)
        {
            var sections = new Dictionary<string, Dictionary<string, string>>();
            string? currentSection = null;

            foreach (var line in File.ReadLines(iniFilePath))
            {
                string trimmedLine = line.Trim();
                if (string.IsNullOrWhiteSpace(trimmedLine) || trimmedLine.StartsWith(";")) continue; // Skip empty lines and comments

                if (trimmedLine.StartsWith("[") && trimmedLine.EndsWith("]"))
                {
                    currentSection = trimmedLine.Trim('[', ']');
                    if (currentSection.StartsWith("UPGRADE"))
                    {
                        sections[currentSection] = new Dictionary<string, string>();
                    }
                }
                else if (currentSection != null && sections.ContainsKey(currentSection))
                {
                    var keyValue = trimmedLine.Split(new[] { '=' }, 2);
                    if (keyValue.Length == 2)
                    {
                        sections[currentSection][keyValue[0].Trim()] = keyValue[1].Trim();
                    }
                }
            }

            return sections;
        }

        /// <summary>
        /// Helper method to get the selected RebootRequired value.
        /// </summary>
        private string GetRebootRequired()
        {
            return selectedRebootOption;
        }
        /// <summary>
        /// Recursively copies all files and subfolders from the source directory to the destination directory.
        /// </summary>
        private void CopyDirectory(string sourceDir, string destinationDir)
        {
            // Create destination directory if it doesn't exist
            Directory.CreateDirectory(destinationDir);

            // Copy all files
            foreach (var file in Directory.GetFiles(sourceDir))
            {
                string destFilePath = System.IO.Path.Combine(destinationDir, System.IO.Path.GetFileName(file));
                File.Copy(file, destFilePath, overwrite: true);
            }

            // Copy all subdirectories
            foreach (var directory in Directory.GetDirectories(sourceDir))
            {
                string destDirPath = System.IO.Path.Combine(destinationDir, System.IO.Path.GetFileName(directory));
                CopyDirectory(directory, destDirPath);
            }
        }

        private void ClearButton_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Clear button clicked!");
            // Add your clear logic here
        }
        private void INIConsole_Click(object sender, RoutedEventArgs e)
        {
            Logger.Info($"Selected INIconsole Page");
            Sidebar.Visibility = Visibility.Hidden;
            // Validate that required fields are not null or empty
            if (string.IsNullOrWhiteSpace(productNameTextBox?.Text) || string.IsNullOrWhiteSpace(fileVersionTextBox?.Text))
            {
                MessageBox.Show("First, add the package before clicking on the INI Console Page.", "Missing Information", MessageBoxButton.OK, MessageBoxImage.Warning);
                Logger.Warn("Attempted to access INI Console Page without setting required fields.");
                return; // Stop execution
            }
            // Example paths for demonstration
            string basePath = @"C:\Temp\PackageConsole"; // Base path
            string productName = productNameTextBox.Text.Trim();
            string productVersion = fileVersionTextBox.Text.Trim();

            // Construct the productFolder and supportFilesFolder paths
            string productFolder = System.IO.Path.Combine(basePath, productName, productVersion, "Altiris");
            string supportFilesFolder = System.IO.Path.Combine(productFolder, "1.0", "SupportFiles");

            // Ensure folders exist
            Directory.CreateDirectory(productFolder);
            Directory.CreateDirectory(supportFilesFolder);

            // Navigate to INIConsolePage, passing the constructed paths

            var iniConsolePage = new IniConsolePage(productFolder, supportFilesFolder);
            MainContentArea.Children.Clear();
            MainContentArea.Children.Add(new Frame { Content = iniConsolePage });
        }

        private void CopyToolkit_Click(object sender, RoutedEventArgs e)
        {
            Sidebar.Visibility = Visibility.Hidden;
            MessageBox.Show("Navigating to Copy Toolkit page...");
            // Add navigation logic here
            MainContentArea.Children.Clear();
            MainContentArea.Children.Add(new Frame { Content = new CopyPackage() });

        }

        private void Testing_Click(object sender, RoutedEventArgs e)
        {
            Logger.Info("Navigating to Testing page...");
            Sidebar.Visibility = Visibility.Hidden;
            // Clear the existing content in MainContentArea
            MainContentArea.Children.Clear();

            // Load the Testing page into the MainContentArea
            var testingPage = new Testing();
            MainContentArea.Children.Add(new Frame { Content = testingPage });
        }

        private void PreviousApps_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Navigating to Previous Apps page...");
            Sidebar.Visibility = Visibility.Hidden;
            // Clear the existing content in MainContentArea
            MainContentArea.Children.Clear();

            // Load the PreviousApps page into the MainContentArea
            var PreviousAppsPage = new PreviousApps();
            MainContentArea.Children.Add(new Frame { Content = PreviousAppsPage });
        }

        private void Settings_Click(object sender, RoutedEventArgs e)
        {
            MessageBox.Show("Navigating to Settings page...");
            Sidebar.Visibility = Visibility.Hidden;
            // Add navigation logic here
        }

        private void PowerBIReport_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://www.google.com",
                UseShellExecute = true
            });
        }

        private void SNOWTool_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://optum.service-now.com/now/nav/ui/classic/params/target/%24vtb.do%3Fsysparm_board%3Da01ca2e0dbb8185462066693ca961938",
                UseShellExecute = true
            });
        }

        private void UPITool_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = @"C:\Users\kbharad7\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\UnitedHealth Group\UHG Package Info - 1 .appref-ms",
                UseShellExecute = true
            });
        }

        private void Button4_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = "https://apps.powerapps.com/play/e/12d07f87-273a-4d38-9810-871dabc8f435/a/eadba983-be54-4199-b2d2-13a48c84623c?tenantId=db05faca-c82a-4b9d-b9c5-0f64b6755421&hint=2e30585f-c036-478d-ae84-9a4b9ecaaae0&sourcetime=1717080620797",
                UseShellExecute = true
            });
        }

        private void Notepad_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = @"C:\Program Files\Notepad++\notepad++.exe",
                UseShellExecute = true
            });
        }

        private void CMTrace_Click(object sender, RoutedEventArgs e)
        {
            Process.Start(new ProcessStartInfo
            {
                FileName = @"C:\Windows\CCM\CMTrace.exe",
                UseShellExecute = true
            });
        }
    }
}