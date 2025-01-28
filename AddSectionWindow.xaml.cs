using System;
using NLog;
using System.Collections.Generic;
using System.Linq;
using System.Windows;
using System.Windows.Controls;

namespace PackageConsole
{
    /// <summary>
    /// Interaction logic for AddSectionWindow.xaml
    /// </summary>
    public partial class AddSectionWindow : Window
    {
        private Dictionary<string, Dictionary<string, string>> iniSections;
        public string SectionName { get; private set; }
        public Dictionary<string, string> KeyValues { get; private set; }

        public AddSectionWindow(Dictionary<string, Dictionary<string, string>> sections)
        {
            InitializeComponent();
            iniSections = sections;
            KeyValues = new Dictionary<string, string>();
            SectionComboBox.ItemsSource = iniSections.Keys.ToList();
        }

        private void SectionComboBox_SelectionChanged(object sender, SelectionChangedEventArgs e)
        {
            if (SectionComboBox.SelectedItem != null)
            {
                string selectedSection = SectionComboBox.SelectedItem.ToString();

                if (selectedSection == "MACHINESPECIFIC1" || selectedSection == "USERSPECIFIC1")
                {
                    LoadMachineOrUserSpecificUI();
                }
                else
                {
                    PopulateSectionData(selectedSection);
                }
            }
        }

        private void LoadMachineOrUserSpecificUI()
        {
            KeyValuePanel.Children.Clear();
            KeyValues.Clear();

            // Create ComboBoxes for TYPE, PLACE, and OPERATION
            var typeComboBox = new ComboBox
            {
                Width = 200,
                Margin = new Thickness(5),
                VerticalAlignment = VerticalAlignment.Center
            };
            typeComboBox.Items.Add("FILE");
            typeComboBox.Items.Add("FOLDER");
            typeComboBox.Items.Add("REGISTRY");

            var placeComboBox = new ComboBox
            {
                Width = 200,
                Margin = new Thickness(5),
                VerticalAlignment = VerticalAlignment.Center
            };
            placeComboBox.Items.Add("PREINSTALL");
            placeComboBox.Items.Add("POSTINSTALL");
            placeComboBox.Items.Add("PREUNINSTALL");
            placeComboBox.Items.Add("POSTUNINSTALL");

            var operationComboBox = new ComboBox
            {
                Width = 200,
                Margin = new Thickness(5),
                VerticalAlignment = VerticalAlignment.Center
            };
            operationComboBox.Items.Add("COPY");
            operationComboBox.Items.Add("DELETE");

            // Add selection handlers
            typeComboBox.SelectionChanged += (sender, e) => UpdateKeyValueFields(typeComboBox, operationComboBox);
            operationComboBox.SelectionChanged += (sender, e) => UpdateKeyValueFields(typeComboBox, operationComboBox);

            // Add ComboBoxes to KeyValuePanel
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

        private void PopulateSectionData(string section)
        {
            KeyValuePanel.Children.Clear();
            KeyValues.Clear();

            if (iniSections.ContainsKey(section))
            {
                foreach (var kvp in iniSections[section])
                {
                    var keyLabel = new Label { Content = kvp.Key, Width = 150, Margin = new Thickness(0, 5, 0, 0) };
                    var valueTextBox = new TextBox { Text = kvp.Value, Width = 150, Margin = new Thickness(5, 5, 0, 0) };

                    var stackPanel = new StackPanel { Orientation = Orientation.Horizontal };
                    stackPanel.Children.Add(keyLabel);
                    stackPanel.Children.Add(valueTextBox);

                    KeyValuePanel.Children.Add(stackPanel);
                    KeyValues[kvp.Key] = kvp.Value;
                }
            }
        }

        private void SaveSection_Click(object sender, RoutedEventArgs e)
        {
            // Ensure that SectionComboBox has a selected item
            if (SectionComboBox.SelectedItem == null)
            {
                MessageBox.Show("Please select a section to determine the insertion point.");
                return;
            }

            string selectedSection = SectionComboBox.SelectedItem.ToString();
            if (string.IsNullOrWhiteSpace(selectedSection))
            {
                MessageBox.Show("The selected section is invalid.");
                return;
            }

            // Generate the new section name
            SectionName = GetIncrementedSectionName(selectedSection);

            // Initialize KeyValues dictionary
            KeyValues = new Dictionary<string, string>();

            // Extract key-value pairs from KeyValuePanel
            foreach (var child in KeyValuePanel.Children)
            {
                if (child is StackPanel stackPanel && stackPanel.Children.Count >= 2)
                {
                    var keyControl = stackPanel.Children[0];
                    var valueControl = stackPanel.Children[1];

                    // Extract key text
                    string keyText = keyControl is TextBlock keyLabel
                        ? keyLabel.Text
                        : (keyControl as Label)?.Content?.ToString();

                    // Extract value text
                    string valueText = valueControl is TextBox valueTextBox
                        ? valueTextBox.Text
                        : (valueControl is ComboBox comboBox && comboBox.SelectedItem != null)
                            ? comboBox.SelectedItem.ToString()
                            : string.Empty;

                    // Add key-value pair if valid
                    if (!string.IsNullOrWhiteSpace(keyText) && valueText != null)
                    {
                        KeyValues[keyText] = valueText;
                    }
                }
            }

            // Ensure KeyValues dictionary is not empty
            if (KeyValues.Count == 0)
            {
                MessageBox.Show("No valid key-value pairs were entered.");
                return;
            }

            // Close the dialog and pass the data back to the parent window
            DialogResult = true;
            Close();
        }

        private StackPanel CreateHorizontalStackPanel(string labelText, Func<UIElement> controlFactory)
        {
            var stackPanel = new StackPanel { Orientation = Orientation.Horizontal, Margin = new Thickness(5) };

            var keyLabel = new TextBlock
            {
                Text = labelText,
                Width = 100,
                VerticalAlignment = VerticalAlignment.Center
            };
            stackPanel.Children.Add(keyLabel);

            var control = controlFactory.Invoke();
            stackPanel.Children.Add(control);

            return stackPanel;
        }

        private string GetIncrementedSectionName(string sectionName)
        {
            var baseName = sectionName.TrimEnd('0', '1', '2', '3', '4', '5', '6', '7', '8', '9');
            var existingSections = iniSections.Keys.Where(s => s.StartsWith(baseName)).ToList();

            int maxNumber = 0;
            foreach (var section in existingSections)
            {
                var numberPart = section.Substring(baseName.Length);
                if (int.TryParse(numberPart, out int number))
                {
                    if (number > maxNumber)
                    {
                        maxNumber = number;
                    }
                }
            }

            return baseName + (maxNumber + 1);
        }
    }
}
