using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Shapes;
using static System.Collections.Specialized.BitVector32;
using NLog;

namespace PackageConsole
{
    /// <summary>
    /// Interaction logic for RemoveSectionWindow.xaml
    /// </summary>
    public partial class RemoveSectionWindow : Window
    {
        private Dictionary<string, Dictionary<string, string>> iniSections;
        public string SelectedSection { get; private set; }
        public RemoveSectionWindow(Dictionary<string, Dictionary<string, string>> sections)
        {
            InitializeComponent();
            iniSections = sections;
            SectionComboBox.ItemsSource = iniSections.Keys;
        }
        private void RemoveSection_Click(object sender, RoutedEventArgs e)
        {
            if (SectionComboBox.SelectedItem != null)
            {
                SelectedSection = SectionComboBox.SelectedItem.ToString();
                DialogResult = true;
                Close();
            }
            else
            {
                MessageBox.Show("Please select a section to remove.");
            }
        }
    }
}
