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
    public partial class IniConsolePage : Page
    {

        private readonly string productFolder;
        private readonly string supportFilesFolder;
        private readonly string iniFilePath;
        private Dictionary<string, Dictionary<string, string>> iniSections = new(); // Initialize to avoid null warnings
        private static readonly Logger Logger = LogManager.GetCurrentClassLogger();
        
        public IniConsolePage(string productFolder, string supportFilesFolder)
        {
            InitializeComponent();
            this.productFolder = productFolder;
            this.supportFilesFolder = supportFilesFolder;
            Logger.Info($"IniConsolePage initialized at  location: {supportFilesFolder}");
            // Initialize iniFilePath
            iniFilePath = System.IO.Path.Combine(supportFilesFolder, "Package.ini");

            LoadIniFile();
        }

        private void LoadIniFile()
        {
            try
            {
                if (!File.Exists(iniFilePath))
                {
                    MessageBox.Show($"INI file not found: {iniFilePath}");
                    Logger.Warn($"INI file not found: {iniFilePath}");
                    IniContentTextBox.Text = string.Empty;
                    return;
                }

                // Declare rawContent to hold raw INI data
                List<string> rawContent;

                // Parse the INI file and retrieve sections and raw content
                iniSections = IniFileHelper.ParseIniFile(iniFilePath, out rawContent);

                if (iniSections == null || !iniSections.Any())
                {
                    MessageBox.Show("The INI file is empty or invalid.");
                    Logger.Warn("The INI file is empty or invalid.");
                    IniContentTextBox.Text = string.Join(Environment.NewLine, rawContent);
                    return;
                }

                // Update the raw content in the INI Content Area
                IniContentTextBox.Text = string.Join(Environment.NewLine, rawContent);

                Logger.Info("INI file loaded successfully.");
                LoadSections();
            }
            catch (Exception ex)
            {
                MessageBox.Show($"Error loading INI file: {ex.Message}");
                Logger.Error($"Error loading INI file: {ex}");
                IniContentTextBox.Text = string.Empty;
            }
        }
        private void LoadSections()
        {
            try
            {
                SectionComboBox.ItemsSource = null;
                SectionComboBox.ItemsSource = iniSections.Keys.ToList();

                if (!iniSections.Keys.Any())
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
        private void LoadKeyValuePairs(string? section)
        {
            if (section == null)
            {
                Logger.Warn("LoadKeyValuePairs called with a null section.");
                return;
            }

            KeyValuePanel.Children.Clear();

            if (section == "MACHINESPECIFIC1" || section == "USERSPECIFIC1")
            {
                LoadMachineOrUserSpecificUI(section);
            }
            else
            {
                // Handle other sections with TextBlock and TextBox
                if (iniSections.TryGetValue(section, out var keyValues))
                {
                    foreach (var kvp in keyValues)
                    {
                        var stackPanel = new StackPanel { Orientation = Orientation.Horizontal, Margin = new Thickness(5) };

                        // TextBlock with white font color
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
                    MessageBox.Show($"No valid key-value pairs found in section [{section}].");
                    Logger.Warn($"No valid key-value pairs found in section [{section}].");
                }
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
            var removeSectionWindow = new RemoveSectionWindow(iniSections);
            if (removeSectionWindow.ShowDialog() == true)
            {
                string selectedSection = removeSectionWindow.SelectedSection;

                if (!string.IsNullOrWhiteSpace(selectedSection) && iniSections.ContainsKey(selectedSection))
                {
                    iniSections.Remove(selectedSection);
                    IniFileHelper.SaveIniFile(iniFilePath, iniSections);
                    LoadSections();
                    UpdateIniContentTextBox();
                    MessageBox.Show($"Section '{selectedSection}' removed successfully.");
                    Logger.Info($"Section '{selectedSection}' removed.");
                }
                else
                {
                    MessageBox.Show("Section name is invalid or does not exist.");
                }
            }
        }
        private void InsertValuesButton_Click(object sender, RoutedEventArgs e)
        {
           string tempIniFilePath = System.IO.Path.Combine(supportFilesFolder, "tmpPackage.ini");
           
            if (!File.Exists(tempIniFilePath))
            {
                MessageBox.Show("Temporary INI file not found.");
                Logger.Warn("Temporary INI file not found.");
                return;
            }

            // Declare rawContent to hold raw INI data
            List<string> rawContent;

            // Parse the temporary INI file
            var tempIniSections = IniFileHelper.ParseIniFile(tempIniFilePath, out rawContent);

            foreach (var section in tempIniSections.Keys)
            {
                if (!iniSections.ContainsKey(section))
                {
                    iniSections[section] = new Dictionary<string, string>();
                }

                foreach (var kv in tempIniSections[section])
                {
                    iniSections[section][kv.Key] = kv.Value;
                }
            }

            IniFileHelper.SaveIniFile(iniFilePath, iniSections);
            LoadSections();
            UpdateIniContentTextBox();
            MessageBox.Show("Values merged and inserted successfully!");
            Logger.Info("Values merged and inserted from temporary INI file.");
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
                iniContentBuilder.AppendLine(); // Add an extra line between sections
            }

            // Update the INI Content TextBox
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
                    // Handle TextBlock and TextBox pairs
                    if (stackPanel.Children[0] is TextBlock keyLabel && stackPanel.Children[1] is TextBox valueTextBox)
                    {
                        string key = keyLabel.Text;
                        string value = valueTextBox.Text;
                        updatedValues[key] = value;
                    }
                    // Handle TextBlock and ComboBox pairs
                    else if (stackPanel.Children[0] is TextBlock comboKeyLabel && stackPanel.Children[1] is ComboBox valueComboBox)
                    {
                        string key = comboKeyLabel.Text;
                        string value = valueComboBox.SelectedItem?.ToString() ?? string.Empty;
                        updatedValues[key] = value;
                    }
                }
            }

            // Update the section in the iniSections dictionary
            if (iniSections.ContainsKey(selectedSection))
            {
                iniSections[selectedSection] = updatedValues;
                IniFileHelper.SaveIniFile(iniFilePath, iniSections);

                // Refresh the PackageINI Content Area
                UpdateIniContentTextBox();

                MessageBox.Show($"Section '{selectedSection}' updated successfully!");
                Logger.Info($"Section '{selectedSection}' updated.");
            }
            else
            {
                MessageBox.Show($"Section '{selectedSection}' not found.");
                Logger.Warn($"Section '{selectedSection}' not found in INI data.");
            }
        }
        private void SectionComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (SectionComboBox.SelectedItem != null)
            {
                var selectedSection = SectionComboBox.SelectedItem.ToString();
                LoadKeyValuePairs(selectedSection);
            }
        }
    }
}
