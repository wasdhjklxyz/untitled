#include <linux/init.h>
#include <linux/module.h>
#include <linux/netdevice.h>

MODULE_LICENSE("GPL-2.0");

struct net_device *dev; // FIXME: Stupid

static void untitled_setup(struct net_device *dev)
{
	printk(KERN_ALERT "untitled: setup\n");
}

static int hello_init(void)
{
	printk(KERN_ALERT "hello world\n");

	dev = alloc_netdev(0, "untitled%d", NET_NAME_UNKNOWN, untitled_setup);
	if (!dev) {
		printk(KERN_ERR "untitled: alloc_netdev\n");
		return -ENOMEM;
	}

	// TODO: Device setup

	/*
	int err = register_netdev(dev);
	if (err) {
		printk(KERN_ERR "untitled: register_netdev\n");
		free_netdev(dev);
		return err;
	}
  */

	return 0;
}

static void hello_exit(void)
{
	printk(KERN_ALERT "goodbye\n");

	// TODO: unregister_netdev(dev);
	free_netdev(dev);
}

module_init(hello_init);
module_exit(hello_exit);
