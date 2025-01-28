using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Windows;
using System.Windows.Controls;
using NLog;

namespace PackageConsole
{
    public partial class PreviousApps : Page
    {
        private Dictionary<string, Dictionary<string, string>> iniSections = new(); // Holds parsed INI sections
        private static readonly Logger Logger = LogManager.GetCurrentClassLogger(); // Logger for error handling and tracing

        public PreviousApps()
        {
            InitializeComponent();
            Logger.Info("PreviousApps Page initialized.");

        }

        private void LoadIniButton_Click(object sender, RoutedEventArgs e)
        {
            OpenFileDialog openFileDialog = new OpenFileDialog
            {
                Filter = "INI files (*.ini)|*.ini",
                Title = "Select an INI file"
            };

            if (openFileDialog.ShowDialog() == true)
            {
                string iniFilePath = openFileDialog.FileName;

                if (!File.Exists(iniFilePath))
                {
                    MessageBox.Show("File does not exist.");
                    Logger.Warn("Selected file does not exist.");
                    return;
                }

                try
                {
                    List<string> rawContent;

                    // Parse the INI file
                    iniSections = IniFileHelper.ParseIniFile(iniFilePath, out rawContent);

                    // Display raw INI file content in the text box
                    IniContentTextBox.Text = string.Join(Environment.NewLine, rawContent);

                    // Handle [PRODUCT INFO] section
                    if (iniSections.TryGetValue("PRODUCT INFO", out var productInfo))
                    {
                        if (productInfo.TryGetValue("APPNAME", out string appName) &&
                             productInfo.TryGetValue("APPVER", out string appVer))
                        {
                            string destinationPath = Path.Combine("C:\\Temp\\PackageConsole", appName, appVer, "1.0");
                            Directory.CreateDirectory(destinationPath);

                            // Copy files from two folders above the selected INI file
                            string sourceFolder = Path.GetFullPath(Path.Combine(iniFilePath, @"..\..\"));
                            if (Directory.Exists(sourceFolder))
                            {
                                foreach (var file in Directory.GetFiles(sourceFolder, "*.*", SearchOption.AllDirectories))
                                {
                                    string relativePath = Path.GetRelativePath(sourceFolder, file);
                                    string destinationFile = Path.Combine(destinationPath, relativePath);

                                    Directory.CreateDirectory(Path.GetDirectoryName(destinationFile)!);
                                    File.Copy(file, destinationFile, overwrite: true);
                                }

                                MessageBox.Show($"Files copied successfully to {destinationPath}");
                                Logger.Info($"Files copied to {destinationPath}");
                                iniFilePath = System.IO.Path.Combine(destinationPath, "SupportFiles", "Package.ini");
                                this.Tag = iniFilePath;
                            }
                            else
                            {
                                MessageBox.Show("Source folder not found.");
                                Logger.Warn("Source folder for copying files not found.");
                            }
                        }
                        else
                        {
                            MessageBox.Show("AppName or AppVer not found in the [PRODUCTINFO] section.");
                            Logger.Warn("[PRODUCTINFO] section missing AppName or AppVer.");
                        }
                    }
                    else
                    {
                        MessageBox.Show("[PRODUCTINFO] section not found in the INI file.");
                        Logger.Warn("[PRODUCTINFO] section not present in the INI file.");
                    }

                    // Refresh the SectionComboBox with updated sections
                    LoadSections();
                }
                catch (Exception ex)
                {
                    MessageBox.Show($"Error: {ex.Message}");
                    Logger.Error($"Error loading INI file: {ex}");
                }
            }
        }

        private void LoadSections()
        {
            try
            {
                SectionComboBox.ItemsSource = null;
                SectionComboBox.ItemsSource = iniSections.Keys.ToList();

                if (!iniSections.Any())
                {
                    Logger.Warn("No sections found in the INI file.");
                    MessageBox.Show("No sections found in the INI file.");
                }
                else
                {
                    Logger.Info($"Sections loaded: {string.Join(", ", iniSections.Keys)}");
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading sections: {ex.Message}");
                Logger.Error($"Error loading sections: {ex}");
            }
        }

        private void SectionComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (SectionComboBox.SelectedItem != null)
            {
                string selectedSection = SectionComboBox.SelectedItem.ToString();
                LoadKeyValuePairs(selectedSection);
            }
        }

        private void LoadKeyValuePairs(string section)
        {
            KeyValuePanel.Children.Clear();

            if (section != null && iniSections.TryGetValue(section, out var keyValues))
            {
                foreach (var kvp in keyValues)
                {
                    var stackPanel = new StackPanel { Orientation = Orientation.Horizontal, Margin = new Thickness(5) };

                    stackPanel.Children.Add(new TextBlock
                    {
                        Text = kvp.Key,
                        Width = 100,
                        VerticalAlignment = VerticalAlignment.Center,
                        Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White)
                    });

                    stackPanel.Children.Add(new TextBox { Text = kvp.Value, Width = 200 });
                    KeyValuePanel.Children.Add(stackPanel);
                }
            }
            else
            {
                MessageBox.Show($"Section [{section}] not found.");
                Logger.Warn($"Section [{section}] not found in the INI data.");
            }
        }

        private void UpdateIniContentTextBox()
        {
            var iniContentBuilder = new StringBuilder();
            foreach (var section in iniSections)
            {
                iniContentBuilder.AppendLine($"[{section.Key}]");
                foreach (var kvp in section.Value)
                {
                    iniContentBuilder.AppendLine($"{kvp.Key}={kvp.Value}");
                }
                iniContentBuilder.AppendLine();
            }

            IniContentTextBox.Text = iniContentBuilder.ToString();
        }
        private void UpdateIniButton_Click(object sender, RoutedEventArgs e)
        {
            if (SectionComboBox.SelectedItem == null)
            {
                MessageBox.Show("No section selected.");
                return;
            }

            string selectedSection = SectionComboBox.SelectedItem.ToString();
            if (string.IsNullOrWhiteSpace(selectedSection))
            {
                MessageBox.Show("Invalid section selected.");
                return;
            }

            var updatedValues = new Dictionary<string, string>();

            // Iterate through the KeyValuePanel children
            foreach (var child in KeyValuePanel.Children)
            {
                if (child is StackPanel stackPanel && stackPanel.Children.Count >= 2)
                {
                    if (stackPanel.Children[0] is TextBlock keyLabel && stackPanel.Children[1] is TextBox valueTextBox)
                    {
                        string key = keyLabel.Text;
                        string value = valueTextBox.Text;
                        updatedValues[key] = value;
                    }
                }
            }

            // Update the INI data
            if (iniSections.ContainsKey(selectedSection))
            {
                iniSections[selectedSection] = updatedValues;
                MessageBox.Show($"Section '{selectedSection}' updated successfully!");
                UpdateIniContentTextBox();
            }
            else
            {
                MessageBox.Show($"Section '{selectedSection}' not found.");
            }
        }
        private void LoadMachineOrUserSpecificUI(string section)
        {
            var typeComboBoxFactory = () =>
            {
                var comboBox = new ComboBox
                {
                    Width = 200,
                    Margin = new Thickness(5),
                    VerticalAlignment = VerticalAlignment.Center
                };
                comboBox.Items.Add("FILE");
                comboBox.Items.Add("FOLDER");
                comboBox.Items.Add("REGISTRY");
                return comboBox;
            };

            var placeComboBoxFactory = () =>
            {
                var comboBox = new ComboBox
                {
                    Width = 200,
                    Margin = new Thickness(5),
                    VerticalAlignment = VerticalAlignment.Center
                };
                comboBox.Items.Add("PREINSTALL");
                comboBox.Items.Add("POSTINSTALL");
                comboBox.Items.Add("PREUNINSTALL");
                comboBox.Items.Add("POSTUNINSTALL");
                return comboBox;
            };

            var operationComboBoxFactory = () =>
            {
                var comboBox = new ComboBox
                {
                    Width = 200,
                    Margin = new Thickness(5),
                    VerticalAlignment = VerticalAlignment.Center
                };
                comboBox.Items.Add("COPY");
                comboBox.Items.Add("DELETE");
                return comboBox;
            };

            // Create ComboBoxes for TYPE, PLACE, and OPERATION
            var typeComboBox = typeComboBoxFactory.Invoke();
            var placeComboBox = placeComboBoxFactory.Invoke();
            var operationComboBox = operationComboBoxFactory.Invoke();

            // Event handlers for dynamic updates
            typeComboBox.SelectionChanged += (sender, e) => UpdateKeyValueFields(typeComboBox, operationComboBox);
            operationComboBox.SelectionChanged += (sender, e) => UpdateKeyValueFields(typeComboBox, operationComboBox);

            // Add initial ComboBoxes to the panel
            KeyValuePanel.Children.Add(CreateHorizontalStackPanel("TYPE", () => typeComboBox));
            KeyValuePanel.Children.Add(CreateHorizontalStackPanel("PLACE", () => placeComboBox));
            KeyValuePanel.Children.Add(CreateHorizontalStackPanel("OPERATION", () => operationComboBox));
        }
        private void UpdateKeyValueFields(ComboBox typeComboBox, ComboBox operationComboBox)
        {
            // Clear dynamic fields
            KeyValuePanel.Children.RemoveRange(3, KeyValuePanel.Children.Count - 3);

            string selectedType = typeComboBox.SelectedItem?.ToString() ?? string.Empty;
            string selectedOperation = operationComboBox.SelectedItem?.ToString() ?? string.Empty;

            if (selectedType == "FILE" || selectedType == "FOLDER")
            {
                if (selectedOperation == "COPY")
                {
                    KeyValuePanel.Children.Add(CreateHorizontalStackPanel("SOURCE", () => new TextBox { Width = 200 }));
                    KeyValuePanel.Children.Add(CreateHorizontalStackPanel("DESTINATION", () => new TextBox { Width = 200 }));
                }
                else if (selectedOperation == "DELETE")
                {
                    KeyValuePanel.Children.Add(CreateHorizontalStackPanel("DELETEFILEFLD", () => new TextBox { Width = 200 }));
                }
            }
            else if (selectedType == "REGISTRY")
            {
                if (selectedOperation == "COPY")
                {
                    KeyValuePanel.Children.Add(CreateHorizontalStackPanel("REGWRITE", () => new TextBox { Width = 200 }));
                }
                else if (selectedOperation == "DELETE")
                {
                    KeyValuePanel.Children.Add(CreateHorizontalStackPanel("REGDELETE", () => new TextBox { Width = 200 }));
                }
            }
        }
        // Helper function to create a horizontal StackPanel with a Label and a control
        private StackPanel CreateHorizontalStackPanel(string labelText, Func<UIElement> controlFactory)
        {
            var stackPanel = new StackPanel { Orientation = Orientation.Horizontal, Margin = new Thickness(5) };

            // Label with white font color
            stackPanel.Children.Add(new TextBlock
            {
                Text = labelText,
                Width = 100,
                VerticalAlignment = VerticalAlignment.Center,
                Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White)
            });

            // Create a new control using the factory function
            var control = controlFactory.Invoke();
            stackPanel.Children.Add(control);

            return stackPanel;
        }
        private void AddSectionButton_Click(object sender, RoutedEventArgs e)
        {

            string iniFilePath = this.Tag as string; // Retrieve stored iniFilePath
            if (string.IsNullOrWhiteSpace(iniFilePath) || !File.Exists(iniFilePath))
            {
                MessageBox.Show("No INI file loaded. Please load an INI file first.");
                return;
            }
            // Open AddSectionWindow to get user input
            var addSectionWindow = new AddSectionWindow(iniSections);
            if (addSectionWindow.ShowDialog() == true)
            {
                // Retrieve the new section name and key-value pairs
                string newSection = addSectionWindow.SectionName;
                var keyValues = addSectionWindow.KeyValues;

                // Validate the new section name
                if (string.IsNullOrWhiteSpace(newSection))
                {
                    MessageBox.Show("Section name cannot be empty.");
                    return;
                }

                if (iniSections.ContainsKey(newSection))
                {
                    MessageBox.Show($"The section '{newSection}' already exists. Please choose a different name.");
                    return;
                }

                // Get the selected section from the ComboBox
                string selectedSection = SectionComboBox.SelectedItem?.ToString();
                var sectionList = iniSections.Keys.ToList();

                if (string.IsNullOrWhiteSpace(selectedSection))
                {
                    MessageBox.Show("No section selected. The new section will be added to the end of the file.");
                    sectionList.Add(newSection); // Add to the end
                }
                else
                {
                    // Insert the new section next to the selected section
                    int selectedIndex = sectionList.IndexOf(selectedSection);
                    if (selectedIndex != -1)
                    {
                        sectionList.Insert(selectedIndex + 1, newSection); // Insert right after selected section
                    }
                    else
                    {
                        sectionList.Add(newSection); // Add to the end if the selected section is not found
                    }
                }

                // Rebuild the iniSections dictionary in the correct order
                var updatedIniSections = new Dictionary<string, Dictionary<string, string>>();
                foreach (var section in sectionList)
                {
                    if (section == newSection)
                    {
                        updatedIniSections[section] = keyValues; // Add the new section
                    }
                    else
                    {
                        updatedIniSections[section] = iniSections[section];
                    }
                }

                // Update iniSections and save changes
                iniSections = updatedIniSections;
                IniFileHelper.SaveIniFile(iniFilePath, iniSections);

                // Refresh UI
                LoadSections();
                UpdateIniContentTextBox();

                // Notify user
                MessageBox.Show($"Section '{newSection}' added successfully next to '{selectedSection}'.");
                Logger.Info($"Section '{newSection}' added next to '{selectedSection}'.");
            }
        }

        private void RemoveSectionButton_Click(object sender, RoutedEventArgs e)
        {
            string iniFilePath = this.Tag as string; // Retrieve stored iniFilePath
            if (string.IsNullOrWhiteSpace(iniFilePath) || !File.Exists(iniFilePath))
            {
                MessageBox.Show("No INI file loaded. Please load an INI file first.");
                return;
            }
            // Open RemoveSectionWindow to get user input
            var removeSectionWindow = new RemoveSectionWindow(iniSections);
            if (removeSectionWindow.ShowDialog() == true)
            {
                string selectedSection = removeSectionWindow.SelectedSection;

                if (!string.IsNullOrWhiteSpace(selectedSection) && iniSections.ContainsKey(selectedSection))
                {
                    // Remove the selected section
                    iniSections.Remove(selectedSection);

                    // Save the updated INI file
                    IniFileHelper.SaveIniFile(iniFilePath, iniSections);

                    // Refresh UI
                    LoadSections();
                    UpdateIniContentTextBox();

                    // Notify user
                    MessageBox.Show($"Section '{selectedSection}' removed successfully.");
                    Logger.Info($"Section '{selectedSection}' removed successfully.");
                }
                else
                {
                    MessageBox.Show("Section name is invalid or does not exist.");
                }
            }
        }

    }
}
